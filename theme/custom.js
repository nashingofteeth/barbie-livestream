'use strict';

(function() {
  /** ========================================
   *  SPARKLE MANAGER
   *  Two types: falling from top + cursor-generated
   *  ======================================== */
  
  const CONFIG = {
    // Ambient sparkles (falling from top)
    maxAmbientSparkles: 15,
    ambientSpawnInterval: 500, // ms between ambient sparkles
    ambientMinDuration: 4000,
    ambientMaxDuration: 7000,
    ambientMinDrift: -30,
    ambientMaxDrift: 30,
    
    // Cursor sparkles
    maxCursorSparkles: 30,
    cursorSpawnThrottle: 80, // ms between cursor sparkles
    cursorMinDuration: 2000,
    cursorMaxDuration: 4000,
    cursorSpreadRadius: 20,
    cursorMinVelocityX: -50,
    cursorMaxVelocityX: 50,
    cursorMinVelocityY: 30,
    cursorMaxVelocityY: 100,
    cursorGravity: 0.5,
  };

  class SparkleManager {
    constructor() {
      this.ambientSparkles = [];
      this.cursorSparkles = [];
      this.isRunning = false;
      this.ambientTimer = null;
      this.lastCursorSpawnTime = 0;
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
      
      // Start ambient sparkles
      this.scheduleNextAmbientSparkle();
      
      // Track mouse movement for cursor sparkles
      document.addEventListener('mousemove', (e) => {
        const now = Date.now();
        if (now - this.lastCursorSpawnTime > CONFIG.cursorSpawnThrottle) {
          if (this.cursorSparkles.length < CONFIG.maxCursorSparkles) {
            this.createCursorSparkle(e.clientX, e.clientY);
          }
          this.lastCursorSpawnTime = now;
        }
      });
    }

    scheduleNextAmbientSparkle() {
      if (!this.isRunning) return;

      this.ambientTimer = setTimeout(() => {
        if (this.ambientSparkles.length < CONFIG.maxAmbientSparkles) {
          this.createAmbientSparkle();
        }
        this.scheduleNextAmbientSparkle();
      }, CONFIG.ambientSpawnInterval + Math.random() * 200);
    }

    createAmbientSparkle() {
      // Create wrapper for position animation
      const sparkle = document.createElement('div');
      sparkle.className = 'sparkle sparkle-ambient';
      
      // Create inner element for twinkle animation
      const sparkleInner = document.createElement('span');
      sparkleInner.className = 'sparkle-inner';
      sparkleInner.textContent = '✨';
      sparkle.appendChild(sparkleInner);

      // Random position across viewport width
      const x = Math.random() * (window.innerWidth - 30);
      
      // Check if position overlaps with video player
      if (this.isOverVideoPlayer(x)) {
        return; // Skip this sparkle
      }

      // Random animation duration
      const duration = CONFIG.ambientMinDuration + Math.random() * (CONFIG.ambientMaxDuration - CONFIG.ambientMinDuration);
      
      // Random horizontal drift
      const drift = CONFIG.ambientMinDrift + Math.random() * (CONFIG.ambientMaxDrift - CONFIG.ambientMinDrift);

      // Apply styles - start at top of viewport plus scroll
      sparkle.style.left = `${x}px`;
      sparkle.style.top = `${window.scrollY - 30}px`;
      sparkle.style.animationDuration = `${duration}ms`;
      sparkle.style.setProperty('--drift-x', `${drift}px`);

      // Add to DOM
      document.body.appendChild(sparkle);
      this.ambientSparkles.push(sparkle);

      // Remove after animation completes
      setTimeout(() => {
        this.removeSparkle(sparkle, 'ambient');
      }, duration);
    }

    createCursorSparkle(x, y) {
      // Create wrapper for position animation
      const sparkle = document.createElement('div');
      sparkle.className = 'sparkle sparkle-cursor';
      
      // Create inner element for twinkle animation
      const sparkleInner = document.createElement('span');
      sparkleInner.className = 'sparkle-inner';
      sparkleInner.textContent = '✨';
      sparkle.appendChild(sparkleInner);

      // Add random offset from cursor position
      const offsetX = (Math.random() - 0.5) * CONFIG.cursorSpreadRadius;
      const offsetY = (Math.random() - 0.5) * CONFIG.cursorSpreadRadius;
      const startX = x + offsetX;
      const startY = y + offsetY;

      // Random animation duration
      const duration = CONFIG.cursorMinDuration + Math.random() * (CONFIG.cursorMaxDuration - CONFIG.cursorMinDuration);
      
      // Random velocity (direction and speed of fall)
      const velocityX = CONFIG.cursorMinVelocityX + Math.random() * (CONFIG.cursorMaxVelocityX - CONFIG.cursorMinVelocityX);
      const velocityY = CONFIG.cursorMinVelocityY + Math.random() * (CONFIG.cursorMaxVelocityY - CONFIG.cursorMinVelocityY);
      
      // Calculate end position based on velocity and gravity
      const durationSec = duration / 1000;
      const endX = startX + (velocityX * durationSec);
      const endY = startY + (velocityY * durationSec) + (0.5 * CONFIG.cursorGravity * Math.pow(durationSec, 2) * 100);

      // Apply styles
      sparkle.style.left = `${startX}px`;
      sparkle.style.top = `${startY}px`;
      sparkle.style.animationDuration = `${duration}ms`;
      sparkle.style.setProperty('--start-x', '0px');
      sparkle.style.setProperty('--start-y', '0px');
      sparkle.style.setProperty('--end-x', `${endX - startX}px`);
      sparkle.style.setProperty('--end-y', `${endY - startY}px`);

      // Add to DOM
      document.body.appendChild(sparkle);
      this.cursorSparkles.push(sparkle);

      // Remove after animation completes
      setTimeout(() => {
        this.removeSparkle(sparkle, 'cursor');
      }, duration);
    }

    isOverVideoPlayer(x) {
      if (!this.videoContainer) return false;

      const rect = this.videoContainer.getBoundingClientRect();
      const sparkleWidth = 30; // approximate width of emoji
      
      // Check if sparkle's horizontal position would overlap video
      return x >= rect.left && x <= (rect.right + sparkleWidth);
    }

    removeSparkle(sparkle, type) {
      const array = type === 'ambient' ? this.ambientSparkles : this.cursorSparkles;
      const index = array.indexOf(sparkle);
      if (index > -1) {
        array.splice(index, 1);
      }
      if (sparkle.parentNode) {
        sparkle.parentNode.removeChild(sparkle);
      }
    }

    stop() {
      this.isRunning = false;
      if (this.ambientTimer) {
        clearTimeout(this.ambientTimer);
      }
      
      // Clean up existing sparkles
      [...this.ambientSparkles, ...this.cursorSparkles].forEach(sparkle => {
        if (sparkle.parentNode) {
          sparkle.parentNode.removeChild(sparkle);
        }
      });
      this.ambientSparkles = [];
      this.cursorSparkles = [];
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
