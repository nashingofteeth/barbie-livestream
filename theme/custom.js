'use strict';

(function() {
  /** ========================================
   *  SPARKLE MANAGER
   *  Floating sparkles that avoid video player
   *  ======================================== */
  
  const CONFIG = {
    maxSparkles: 25,
    spawnInterval: 400, // ms between sparkles
    minDuration: 4000, // min animation duration
    maxDuration: 7000, // max animation duration
    minDrift: -30, // min horizontal drift (px)
    maxDrift: 30, // max horizontal drift (px)
  };

  class SparkleManager {
    constructor() {
      this.sparkles = [];
      this.isRunning = false;
      this.spawnTimer = null;
      this.videoContainer = null;
    }

    init() {
      // Wait for DOM to be ready
      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => this.start());
      } else {
        this.start();
      }
    }

    start() {
      this.isRunning = true;
      this.videoContainer = document.querySelector('#video-container');
      this.scheduleNextSparkle();
    }

    scheduleNextSparkle() {
      if (!this.isRunning) return;

      this.spawnTimer = setTimeout(() => {
        if (this.sparkles.length < CONFIG.maxSparkles) {
          this.createSparkle();
        }
        this.scheduleNextSparkle();
      }, CONFIG.spawnInterval + Math.random() * 200);
    }

    createSparkle() {
      // Create wrapper for position animation
      const sparkle = document.createElement('div');
      sparkle.className = 'sparkle';
      
      // Create inner element for twinkle animation
      const sparkleInner = document.createElement('span');
      sparkleInner.className = 'sparkle-inner';
      sparkleInner.textContent = '✨';
      sparkle.appendChild(sparkleInner);

      // Random position across viewport width
      const x = Math.random() * (window.innerWidth - 30);
      
      // Check if position overlaps with video player
      if (this.isOverVideoPlayer(x)) {
        // Skip this sparkle if it would cover the video
        return;
      }

      // Random animation duration
      const duration = CONFIG.minDuration + Math.random() * (CONFIG.maxDuration - CONFIG.minDuration);
      
      // Random horizontal drift
      const drift = CONFIG.minDrift + Math.random() * (CONFIG.maxDrift - CONFIG.minDrift);

      // Apply styles - start at top of viewport plus scroll
      sparkle.style.left = `${x}px`;
      sparkle.style.top = `${window.scrollY - 30}px`;
      sparkle.style.animationDuration = `${duration}ms`;
      sparkle.style.setProperty('--drift-x', `${drift}px`);

      // Add to DOM
      document.body.appendChild(sparkle);
      this.sparkles.push(sparkle);

      // Remove after animation completes
      setTimeout(() => {
        this.removeSparkle(sparkle);
      }, duration);
    }

    isOverVideoPlayer(x) {
      if (!this.videoContainer) return false;

      const rect = this.videoContainer.getBoundingClientRect();
      const sparkleWidth = 30; // approximate width of emoji
      
      // Check if sparkle's horizontal position would overlap video
      return x >= rect.left && x <= (rect.right + sparkleWidth);
    }

    removeSparkle(sparkle) {
      const index = this.sparkles.indexOf(sparkle);
      if (index > -1) {
        this.sparkles.splice(index, 1);
      }
      if (sparkle.parentNode) {
        sparkle.parentNode.removeChild(sparkle);
      }
    }

    stop() {
      this.isRunning = false;
      if (this.spawnTimer) {
        clearTimeout(this.spawnTimer);
      }
      // Clean up existing sparkles
      this.sparkles.forEach(sparkle => {
        if (sparkle.parentNode) {
          sparkle.parentNode.removeChild(sparkle);
        }
      });
      this.sparkles = [];
    }
  }

  // Initialize sparkle manager
  const sparkleManager = new SparkleManager();
  sparkleManager.init();

  // Cleanup on page unload
  window.addEventListener('beforeunload', () => {
    sparkleManager.stop();
  });
})();
