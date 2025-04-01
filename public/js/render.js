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

  defaultShape(lf) {
    new Konva.Circle({
      x: lf.x * this.zf,
      y: lf.y * this.zf,
      radius: lf.size / 2.0 * this.zf,
      fill: 'blue',
      stroke: 'black',
      opacity: 0.5,
      strokeWidth: 1
    });
  }

  getShape(lf) {
    switch(lf.species) {
      case 'Plant':
        return Konva.Image.fromURL("/images/tree.png", function(image){});
        break;
      case 'Grazer':
        return Konva.Image.fromURL("/images/cow.png", function(image){});
        break;
      default:
        return this.defaultShape(lf)
        break;
    }
  }

  addLifeform(lf) {
    let imgURL = "/images/tree.png"
    let layer = this.layer
    const imageObj = new Image();
    imageObj.onload = function () {
      const tree = new Konva.Image({
        x: 50,
        y: 50,
        image: imageObj,
        width: 100,
        height: 100
      });
    
      layer.add(tree);
    };
    imageObj.src = imgURL;
  }

  render() {
    this.stage.add(this.layer);
    this.layer.draw();
  }
}