/**
 * BARBIE DREAMHOUSE THEME - SPARKLE EFFECTS
 * Adds floating sparkle particles to the Owncast stream page
 */

(function() {
  'use strict';

  // Configuration
  const CONFIG = {
    maxSparkles: 30,
    spawnInterval: 300,
    sparkleLifetime: 5000,
    minSize: 2,
    maxSize: 6,
    colors: ['#FFFFFF', '#FFD700', '#FF69B4', '#FFB6C1']
  };

  // Create sparkle element
  function createSparkle() {
    const sparkle = document.createElement('div');
    const size = Math.random() * (CONFIG.maxSize - CONFIG.minSize) + CONFIG.minSize;
    const color = CONFIG.colors[Math.floor(Math.random() * CONFIG.colors.length)];
    const leftPosition = Math.random() * 100;
    const animationDuration = Math.random() * 3 + 2;
    const animationDelay = Math.random() * 2;
    
    sparkle.style.cssText = `
      position: fixed;
      width: ${size}px;
      height: ${size}px;
      background: ${color};
      border-radius: 50%;
      pointer-events: none;
      z-index: 9999;
      left: ${leftPosition}%;
      bottom: -10px;
      box-shadow: 0 0 ${size * 2}px ${color};
      animation: sparkleFloat ${animationDuration}s linear ${animationDelay}s infinite;
      opacity: 0;
    `;
    
    return sparkle;
  }

  // Add CSS animation for sparkles
  function injectSparkleStyles() {
    if (document.getElementById('barbie-sparkle-styles')) return;
    
    const style = document.createElement('style');
    style.id = 'barbie-sparkle-styles';
    style.textContent = `
      @keyframes sparkleFloat {
        0% {
          transform: translateY(0) rotate(0deg) scale(0);
          opacity: 0;
        }
        10% {
          opacity: 1;
          transform: translateY(-10vh) rotate(36deg) scale(1);
        }
        50% {
          opacity: 1;
          transform: translateY(-50vh) rotate(180deg) scale(1);
        }
        90% {
          opacity: 1;
          transform: translateY(-90vh) rotate(324deg) scale(1);
        }
        100% {
          transform: translateY(-100vh) rotate(360deg) scale(0);
          opacity: 0;
        }
      }

      @keyframes shimmerGlow {
        0%, 100% {
          filter: brightness(1) drop-shadow(0 0 5px rgba(255, 105, 180, 0.3));
        }
        50% {
          filter: brightness(1.2) drop-shadow(0 0 15px rgba(255, 215, 0, 0.6));
        }
      }

      /* Add shimmer to video container */
      #video-container {
        animation: shimmerGlow 3s ease-in-out infinite;
      }

      /* Cursor sparkle trail */
      body {
        cursor: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><text y="20" font-size="20">✨</text></svg>'), auto;
      }

      /* Button sparkle effect on hover */
      button:hover::after,
      #follow-button:hover::after {
        content: "✨";
        position: absolute;
        right: -20px;
        animation: sparkleRotate 1s ease-in-out infinite;
      }

      @keyframes sparkleRotate {
        0%, 100% { transform: rotate(0deg) scale(1); }
        50% { transform: rotate(180deg) scale(1.2); }
      }
    `;
    document.head.appendChild(style);
  }

  // Sparkle manager
  const SparkleManager = {
    sparkles: [],
    isRunning: false,
    spawnIntervalId: null,

    init() {
      injectSparkleStyles();
      this.start();
      console.log('✨ Barbie Dreamhouse sparkles activated!');
    },

    start() {
      if (this.isRunning) return;
      this.isRunning = true;

      // Create initial batch
      for (let i = 0; i < 10; i++) {
        setTimeout(() => this.spawn(), i * 100);
      }

      // Continuous spawning
      this.spawnIntervalId = setInterval(() => {
        if (this.sparkles.length < CONFIG.maxSparkles) {
          this.spawn();
        }
      }, CONFIG.spawnInterval);
    },

    stop() {
      this.isRunning = false;
      if (this.spawnIntervalId) {
        clearInterval(this.spawnIntervalId);
        this.spawnIntervalId = null;
      }
      this.sparkles.forEach(s => s.remove());
      this.sparkles = [];
    },

    spawn() {
      const sparkle = createSparkle();
      document.body.appendChild(sparkle);
      this.sparkles.push(sparkle);

      // Remove after lifetime
      setTimeout(() => {
        sparkle.remove();
        const index = this.sparkles.indexOf(sparkle);
        if (index > -1) {
          this.sparkles.splice(index, 1);
        }
      }, CONFIG.sparkleLifetime);
    }
  };

  // Add special effects to chat messages
  function enhanceChatMessages() {
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        mutation.addedNodes.forEach((node) => {
          if (node.nodeType === 1 && node.classList.contains('chat-message_user')) {
            // Add sparkle to new messages
            const sparkleSpan = document.createElement('span');
            sparkleSpan.textContent = ' ✨';
            sparkleSpan.style.opacity = '0';
            sparkleSpan.style.transition = 'opacity 0.5s ease';
            node.appendChild(sparkleSpan);
            
            setTimeout(() => {
              sparkleSpan.style.opacity = '1';
            }, 100);
            
            setTimeout(() => {
              sparkleSpan.style.opacity = '0';
              setTimeout(() => sparkleSpan.remove(), 500);
            }, 2000);
          }
        });
      });
    });

    // Observe chat container
    const chatContainer = document.querySelector('#chat-container');
    if (chatContainer) {
      observer.observe(chatContainer, { childList: true, subtree: true });
    }
  }

  // Add welcome message
  function showWelcomeMessage() {
    const banner = document.querySelector('#offline-banner');
    if (banner && !banner.classList.contains('barbie-enhanced')) {
      banner.classList.add('barbie-enhanced');
      banner.style.position = 'relative';
      banner.style.overflow = 'visible';
      
      // Add decorative sparkles to offline banner
      const leftSparkle = document.createElement('span');
      leftSparkle.textContent = '✨';
      leftSparkle.style.cssText = `
        position: absolute;
        left: -30px;
        top: 50%;
        transform: translateY(-50%);
        font-size: 2rem;
        animation: sparkleRotate 3s ease-in-out infinite;
      `;
      
      const rightSparkle = leftSparkle.cloneNode(true);
      rightSparkle.style.left = 'auto';
      rightSparkle.style.right = '-30px';
      rightSparkle.style.animationDelay = '1.5s';
      
      banner.appendChild(leftSparkle);
      banner.appendChild(rightSparkle);
    }
  }

  // Initialize when DOM is ready
  function initialize() {
    SparkleManager.init();
    enhanceChatMessages();
    
    // Check for offline banner periodically
    setInterval(showWelcomeMessage, 1000);
    showWelcomeMessage();
    
    console.log('✨ Welcome to the Barbie Dreamhouse! ✨');
  }

  // Wait for page load
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initialize);
  } else {
    initialize();
  }

  // Stop sparkles when page is hidden (performance optimization)
  document.addEventListener('visibilitychange', () => {
    if (document.hidden) {
      SparkleManager.stop();
    } else {
      SparkleManager.start();
    }
  });

})();
