class Render {
  /*
    id: Name of div
    width & height: environment dimensions
    zf: # of pixels per unit distance in simulation
  */
  constructor(id, width, height, zf) {
    this.zf = zf
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

  addDefaultShape(lf) {
    let shape = new Konva.Circle({
      x: lf.x * this.zf,
      y: lf.y * this.zf,
      radius: lf.size / 2.0 * this.zf,
      fill: 'blue',
      stroke: 'black',
      opacity: 0.5,
      strokeWidth: 1
    });
    this.layer.add(shape)
  }

  addImage(lf, imgURL) {
    let layer = this.layer
    let zf = this.zf
    const imageObj = new Image();
    imageObj.onload = function () {
      const kImg = new Konva.Image({
        x: (lf.x - (lf.size / 2.0)) * zf,
        y: (lf.y - (lf.size / 2.0)) * zf,
        image: imageObj,
        width: lf.size * zf,
        height: lf.size * zf,
        opacity: 0.5
      });
    
      layer.add(kImg);
    };
    imageObj.src = imgURL;
  }

  addLifeform(lf) {
    switch(lf.species) {
      case 'Plant':
        return this.addImage(lf, "/images/tree.png")
        break;
      case 'Grazer':
        return this.addImage(lf, "/images/cow.png")
        break;
      default:
        return this.addDefaultShape(lf)
        break;
    }
  }

  render() {
    this.stage.add(this.layer);
    this.layer.draw();
  }
}