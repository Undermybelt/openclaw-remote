#!/bin/bash
# Twitter Timeline Summary Script
# 每小时读取 Twitter 时间线并发送总结

export PATH="$HOME/.npm-global/bin:$PATH"
SESSION_ID="1"
OUTPUT_FILE="/tmp/twitter-timeline-$(date +%s).json"

# 确保浏览器在 Twitter 主页
playwriter -s $SESSION_ID -e "
await page.goto('https://x.com/home');
await page.waitForTimeout(3000);
" --timeout 30000 2>/dev/null

# 获取时间线内容
playwriter -s $SESSION_ID -e "
const tweets = await page.evaluate(() => {
  const articles = document.querySelectorAll('article');
  const results = [];
  articles.forEach((article, i) => {
    if (i < 15) {
      const text = article.querySelector('[data-testid=\"tweetText\"]');
      const author = article.querySelector('[data-testid=\"User-Name\"]');
      if (text) {
        results.push({
          author: author ? author.innerText.split('\\n').slice(0,2).join(' ') : 'Unknown',
          text: text.innerText.substring(0, 280),
          time: new Date().toISOString()
        });
      }
    }
  });
  return results;
});
console.log(JSON.stringify({tweets, fetchedAt: new Date().toISOString()}));
" --timeout 30000 2>&1 | grep -v '^\[' > "$OUTPUT_FILE"

echo "Twitter timeline saved to $OUTPUT_FILE"
cat "$OUTPUT_FILE"
