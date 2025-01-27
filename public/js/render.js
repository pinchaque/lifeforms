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

    this.stage = new Konva.Stage({
      container: id,
      width: width,
      height: height
    });

    this.layer = new Konva.Layer();
  }

  addLifeforms(lfs) {
    lfs.forEach(addLifeform);
  }

  addLifeform(lf) {
    /* 
      add json of lifeforms
      - location
      - color
      - shape
      - mouseover details
    */
    var circle = new Konva.Circle({
      x: stage.width() / 2,
      y: stage.height() / 2,
      radius: 70,
      fill: 'red',
      stroke: 'black',
      strokeWidth: 4
    });

    this.layer.add(circle);
  }

  render() {
    this.stage.add(this.layer);
    this.layer.draw();
  }
}