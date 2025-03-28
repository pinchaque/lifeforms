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

  lfColor(lf) {
    switch(lf.species) {
      case 'Plant':
        return 'green'
        break;
      case 'Grazer':
        return 'blue'
        break;
      default:
        return 'black'
        break;
    }
  }

  addLifeform(lf) {
    var circle = new Konva.Circle({
      x: lf.x * this.zf,
      y: lf.y * this.zf,
      radius: lf.size / 2.0 * this.zf,
      fill: this.lfColor(lf),
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