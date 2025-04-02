describe "Scribe::Formatter" do
  context "File" do
    let(:basename) { "formatter_test" }
   
    context ".file_name" do
      let(:dir) { "/tmp" }
      let(:out) { Scribe::Outputter::File.new(dir, basename) }

      it "base log file name" do
        expect(out.file_name).to eq("/tmp/formatter_test.log")
      end

      it "indexed log file name" do
        expect(out.file_name(0)).to eq("/tmp/formatter_test.log.0")
        expect(out.file_name(3)).to eq("/tmp/formatter_test.log.3")
      end
    end

    context ".initialize" do
      it "creates missing directory" do
        Dir.mktmpdir do |base_dir|
          # should have created the temp dir
          expect(Dir.exist?(base_dir)).to be true

          # subdir is not created yet
          missing_dir = base_dir + "/xxx"
          expect(Dir.exist?(missing_dir)).to be false

          o = Scribe::Outputter::File.new(missing_dir, basename)

          # that dir and log file should exist now
          expect(Dir.exist?(missing_dir)).to be true
          expect(File.exist?(o.file_name)).to be true
          expect(File.size(o.file_name)).to eq(0)

          # our numeric files shouldn't exist
          expect(File.exist?(o.file_name(1))).to be false
        end
      end
    end

    def t_file(file_name, contents_exp)
      if contents_exp.nil?
        expect(File.exist?(file_name)).to be false
      else
        expect(File.exist?(file_name)).to be true
        expect(File.size(file_name)).to eq(contents_exp.length)
        expect(File.read(file_name)).to eq(contents_exp)
      end
    end

    context ".<<" do
      it "adds to log file" do
        Dir.mktmpdir do |dir|
          out = Scribe::Outputter::File.new(dir, basename)
          t_file(out.file_name, "")
          out << "foobar"
          t_file(out.file_name, "foobar")
          out << "quux"
          t_file(out.file_name, "foobarquux")
          out << "booyeah"
          t_file(out.file_name, "foobarquuxbooyeah")
        end
      end
    end

    context ".rotate" do
      def t_files(h)
        h.each do |file_name, contents_exp|
          t_file(file_name, contents_exp)
        end
      end

      it "rotates with num_retain 2" do
        Dir.mktmpdir do |dir|
          out = Scribe::Outputter::File.new(dir, basename)
          out.rotate_size = 4
          out.num_retain = 2

          # so at this point we should just have our base log file
          t_files({
            out.file_name => "",
            out.file_name(0) => nil,  
            out.file_name(1) => nil,  
            out.file_name(2) => nil,  
            out.file_name(3) => nil,  
            out.file_name(4) => nil
          })

          # we should still be within size limit
          out << "foo"
          t_files({
            out.file_name => "foo",
            out.file_name(0) => nil,  
            out.file_name(1) => nil,  
            out.file_name(2) => nil,  
            out.file_name(3) => nil,  
            out.file_name(4) => nil
          })

          # this should put us over and cause rotation
          out << "bar"
          t_files({
            out.file_name => "",
            out.file_name(0) => nil,  
            out.file_name(1) => "foobar",  
            out.file_name(2) => nil,  
            out.file_name(3) => nil,  
            out.file_name(4) => nil
          })

          # no need to rotate
          out << "quux"
          t_files({
            out.file_name => "quux",
            out.file_name(0) => nil,  
            out.file_name(1) => "foobar",  
            out.file_name(2) => nil,  
            out.file_name(3) => nil,  
            out.file_name(4) => nil
          })

          # rotate again
          out << "quux"
          t_files({
            out.file_name => "",
            out.file_name(0) => nil,  
            out.file_name(1) => "quuxquux",
            out.file_name(2) => "foobar",
            out.file_name(3) => nil,  
            out.file_name(4) => nil
          })

          # trigger another rotation, and this time we should lose a log file
          # rotate again
          out << "lossy log"
          t_files({
            out.file_name => "",
            out.file_name(0) => nil,  
            out.file_name(1) => "lossy log",
            out.file_name(2) => "quuxquux",
            out.file_name(3) => nil,  
            out.file_name(4) => nil
          })
        end
      end


      it "rotates with num_retain 0" do
        Dir.mktmpdir do |dir|
          out = Scribe::Outputter::File.new(dir, basename)
          out.rotate_size = 4
          out.num_retain = 0

          # so at this point we should just have our base log file
          t_files({
            out.file_name => "",
            out.file_name(0) => nil,  
            out.file_name(1) => nil,  
            out.file_name(2) => nil,  
            out.file_name(3) => nil,  
            out.file_name(4) => nil
          })

          # we should still be within size limit
          out << "foo"
          t_files({
            out.file_name => "foo",
            out.file_name(0) => nil,  
            out.file_name(1) => nil,  
            out.file_name(2) => nil,  
            out.file_name(3) => nil,  
            out.file_name(4) => nil
          })

          # when we rotate we should just clear and lose the log
          out << "bar"
          t_files({
            out.file_name => "",
            out.file_name(0) => nil,  
            out.file_name(1) => nil,  
            out.file_name(2) => nil,  
            out.file_name(3) => nil,  
            out.file_name(4) => nil
          })
        end
      end
    end

    context "exceptions" do
      let(:out) { Scribe::Outputter::File.new(dir, basename) }
      context "cannot create log dir" do
        let(:dir) { "/xxxxx" }
        it "fails to initialize" do
          expect{out}.to raise_error("Failed to create log directory '/xxxxx'")
        end
      end

      context "non-writeable log dir" do
        let(:dir) { "/bin" }
        it "fails to initialize" do
          expect{out}.to raise_error("Failed to create log file '/bin/formatter_test.log'")
        end
      end
    end
  end
end