import { useEffect, useRef, useState } from 'react';

const GLOW_SIZE = 50;

export function CursorGlow() {
  const glowRef = useRef<HTMLDivElement>(null);
  const [enabled, setEnabled] = useState(false);
  const [visible, setVisible] = useState(false);
  const [isDark, setIsDark] = useState(
    () =>
      typeof window !== 'undefined' &&
      document.documentElement.classList.contains('dark')
  );

  useEffect(() => {
    if (!window.matchMedia('(pointer: fine)').matches) return;
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

    setEnabled(true);

    const observer = new MutationObserver(() => {
      setIsDark(document.documentElement.classList.contains('dark'));
    });
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class'],
    });
    return () => observer.disconnect();
  }, []);

  useEffect(() => {
    if (!enabled) return;

    const glow = glowRef.current;
    if (!glow) return;

    const offset = GLOW_SIZE / 2;
    const EASING = 0.6;
    const SETTLE_THRESHOLD = 0.5;

    let raf = 0;
    let running = false;
    let lastTime = 0;
    let targetX = 0;
    let targetY = 0;
    let x = 0;
    let y = 0;
    let hasMoved = false;

    const render = () => {
      glow.style.transform = `translate3d(${x - offset}px, ${y - offset}px, 0)`;
    };

    const tick = (time: number) => {
      const dt = Math.min((time - lastTime) / 16.667, 3);
      lastTime = time;

      const factor = 1 - Math.pow(1 - EASING, dt);
      x += (targetX - x) * factor;
      y += (targetY - y) * factor;
      render();

      const dist = Math.hypot(targetX - x, targetY - y);
      if (dist > SETTLE_THRESHOLD) {
        raf = requestAnimationFrame(tick);
      } else {
        running = false;
      }
    };

    const start = () => {
      if (!running) {
        running = true;
        lastTime = performance.now();
        raf = requestAnimationFrame(tick);
      }
    };

    const onMouseMove = (e: MouseEvent) => {
      targetX = e.clientX;
      targetY = e.clientY;
      if (!hasMoved) {
        hasMoved = true;
        x = targetX;
        y = targetY;
        render();
        setVisible(true);
      }
      start();
    };

    const onMouseLeave = () => setVisible(false);
    const onMouseEnter = () => {
      if (hasMoved) setVisible(true);
    };

    window.addEventListener('mousemove', onMouseMove, { passive: true });
    document.documentElement.addEventListener('mouseleave', onMouseLeave);
    document.documentElement.addEventListener('mouseenter', onMouseEnter);

    return () => {
      window.removeEventListener('mousemove', onMouseMove);
      document.documentElement.removeEventListener('mouseleave', onMouseLeave);
      document.documentElement.removeEventListener('mouseenter', onMouseEnter);
      if (raf) cancelAnimationFrame(raf);
    };
  }, [enabled]);

  if (!enabled) return null;

  return (
    <div
      ref={glowRef}
      aria-hidden="true"
      className="pointer-events-none fixed left-0 top-0 will-change-transform"
      style={{
        width: GLOW_SIZE,
        height: GLOW_SIZE,
        borderRadius: '50%',
        background: isDark
          ? 'radial-gradient(circle, rgba(59, 130, 246, 0.10) 0%, rgba(59, 130, 246, 0.055) 35%, rgba(59, 130, 246, 0.02) 60%, rgba(59, 130, 246, 0) 100%)'
          : 'radial-gradient(circle, rgba(37, 99, 235, 0.07) 0%, rgba(37, 99, 235, 0.038) 35%, rgba(37, 99, 235, 0.014) 60%, rgba(37, 99, 235, 0) 100%)',
        opacity: visible ? 1 : 0,
        transition: 'opacity 700ms ease',
      }}
    />
  );
}
