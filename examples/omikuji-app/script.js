// Fortune results array with all omikuji fortunes
const fortunes = [
  {
    level: "大吉",
    rank: "daikichi",
    message: "素晴らしい運勢です！",
    luckyItem: "赤いペン",
    luckyColor: "金色"
  },
  {
    level: "中吉",
    rank: "kichi",
    message: "良いことがありますよ",
    luckyItem: "ハンカチ",
    luckyColor: "青"
  },
  {
    level: "小吉",
    rank: "shokichi",
    message: "小さな幸せが訪れます",
    luckyItem: "マグカップ",
    luckyColor: "ピンク"
  },
  {
    level: "吉",
    rank: "kichi",
    message: "穏やかな日々です",
    luckyItem: "めがね",
    luckyColor: "緑"
  },
  {
    level: "末吉",
    rank: "suekichi",
    message: "少し運気上昇中",
    luckyItem: "ノート",
    luckyColor: "黄色"
  },
  {
    level: "凶",
    rank: "kyo",
    message: "気をつけて過ごしてください",
    luckyItem: "お守り",
    luckyColor: "黒"
  }
];

// Draw history tracking
let drawHistory = [];

// DOM elements
const appContainer = document.querySelector('.app-container');
const fortuneDisplay = document.querySelector('.fortune-display');
const drawButton = document.getElementById('draw-btn');
const resetButton = document.getElementById('reset-btn');
const historyList = document.querySelector('.history-list');
const historyEmpty = document.querySelector('.history-empty');

/**
 * Draw a random fortune
 */
function drawFortune() {
  const randomIndex = Math.floor(Math.random() * fortunes.length);
  const fortune = fortunes[randomIndex];

  // Add to history
  drawHistory.unshift({
    fortune: fortune,
    timestamp: new Date().toLocaleTimeString('ja-JP', { hour: '2-digit', minute: '2-digit' })
  });

  // Update state
  appContainer.classList.remove('state-empty', 'state-reset');
  appContainer.classList.add('state-active');

  // Update display
  updateFortuneDisplay(fortune);
  updateHistoryDisplay();
}

/**
 * Update the main fortune display area
 */
function updateFortuneDisplay(fortune) {
  fortuneDisplay.setAttribute('data-rank', fortune.rank);
  fortuneDisplay.innerHTML = `
    <div class="fortune-rank">${fortune.level}</div>
    <p class="fortune-message">${fortune.message}</p>
    <div class="fortune-details">
      <div class="fortune-detail-item">
        <span class="fortune-detail-label">ラッキーアイテム</span>
        <span class="fortune-detail-value">${fortune.luckyItem}</span>
      </div>
      <div class="fortune-detail-item">
        <span class="fortune-detail-label">ラッキーカラー</span>
        <span class="fortune-detail-value">${fortune.luckyColor}</span>
      </div>
    </div>
  `;
}

/**
 * Update the history display
 */
function updateHistoryDisplay() {
  if (drawHistory.length === 0) {
    historyEmpty.hidden = false;
    historyList.hidden = true;
    historyList.innerHTML = '';
    return;
  }

  historyEmpty.hidden = true;
  historyList.hidden = false;
  historyList.innerHTML = '';

  drawHistory.forEach((entry, index) => {
    const historyItem = document.createElement('div');
    historyItem.className = 'history-item';
    historyItem.setAttribute('data-rank', entry.fortune.rank);
    historyItem.innerHTML = `
      <span class="history-time">${entry.timestamp}</span>
      <span class="history-rank">${entry.fortune.level}</span>
    `;
    historyList.appendChild(historyItem);
  });
}

/**
 * Reset the app to initial state
 */
function resetApp() {
  drawHistory = [];

  // Update state
  appContainer.classList.remove('state-active', 'state-reset');
  appContainer.classList.add('state-empty');

  // Reset fortune display
  fortuneDisplay.removeAttribute('data-rank');
  fortuneDisplay.innerHTML = '<p class="placeholder">おみくじを引いてください</p>';

  // Reset history
  updateHistoryDisplay();

  // Add reset animation class briefly
  appContainer.classList.add('state-reset');
  setTimeout(() => {
    appContainer.classList.remove('state-reset');
    appContainer.classList.add('state-empty');
  }, 300);
}

// Event listeners
drawButton.addEventListener('click', drawFortune);
resetButton.addEventListener('click', resetApp);

// Initialize
appContainer.classList.add('state-empty');
updateHistoryDisplay();
