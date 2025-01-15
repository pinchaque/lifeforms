

function drawCanvas(id) {
    const canvas = document.getElementById(id);
    const ctx = canvas.getContext("2d");

    ctx.beginPath();
    ctx.moveTo(20, 20);
    ctx.lineTo(20, 100);
    ctx.lineTo(70, 100);
    ctx.stroke();
}

export default drawCanvas