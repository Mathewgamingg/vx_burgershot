// ===== Custom TextUI - Burger Shot =====

const el     = document.getElementById('textui');
const keyEl  = document.getElementById('textui-key');
const labelEl= document.getElementById('textui-label');

let currentPos = 'right-center';

function setPosition(pos) {
    if (!pos || pos === currentPos) return;
    el.classList.remove('pos-left-center', 'pos-top-center', 'pos-bottom-center');
    if (pos === 'left-center')   el.classList.add('pos-left-center');
    if (pos === 'top-center')    el.classList.add('pos-top-center');
    if (pos === 'bottom-center') el.classList.add('pos-bottom-center');
    currentPos = pos;
}

function show(data) {
    keyEl.textContent   = data.key   || 'E';
    labelEl.textContent = data.label || '';
    if (data.position) setPosition(data.position);
    el.classList.remove('hidden');
    // force reflow pro plynulou animaci
    void el.offsetWidth;
    el.classList.add('visible');
}

function hide() {
    el.classList.remove('visible');
    setTimeout(() => {
        if (!el.classList.contains('visible')) el.classList.add('hidden');
    }, 200);
}

window.addEventListener('message', (event) => {
    const data = event.data || {};
    switch (data.action) {
        case 'showTextUI':
            show(data);
            break;
        case 'hideTextUI':
            hide();
            break;
    }
});
