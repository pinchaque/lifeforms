class Render {
  constructor(id, width, height, env_width, env_height) {
    /* 
      factors to convert environment to canvas
      if canvas is 500 and environment is 100 then env2c_width is 5
      so when we get an environment value of 25 then on the canvas it is
      25 * 5 = 125
    */
    this.env2c_width = width / env_width
    this.env2c_height = height / env_height
    this.env2c_size = (this.env2c_width + this.env2c_height) / 2.0

    this.stage = new Konva.Stage({
      container: id,
      width: width,
      height: height
    });

    this.layer = new Konva.Layer();
  }

  addLifeforms(lfs) {
    let n = lfs.length;
    for (let i = 0; i < n; i++) {
      this.addLifeform(lfs[i]);
    }
  }

  addLifeform(lf) {
    var circle = new Konva.Circle({
      x: lf.x * this.env2c_width,
      y: lf.y * this.env2c_height,
      radius: lf.size * this.env2c_size,
      fill: 'green',
      stroke: 'black',
      opacity: 0.5,
      strokeWidth: 1
    });

    this.layer.add(circle);
  }

  render() {
    this.stage.add(this.layer);
    this.layer.draw();
  }
}