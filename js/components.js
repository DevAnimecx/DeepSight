(function () {
  'use strict';

  const GITHUB_REPO = 'https://github.com/DevAnimecx/deepsight';
  const HOME_URL = 'index.html';

  async function loadComponent(url, targetId, fallback) {
    const target = document.getElementById(targetId);
    if (!target) return;
    try {
      const res = await fetch(url, { cache: 'no-store' });
      if (!res.ok) throw new Error('HTTP ' + res.status);
      target.innerHTML = await res.text();
      if (typeof fallback === 'function') fallback(target);
    } catch (e) {
      console.warn('Failed to load component:', url, e);
      target.innerHTML = '<div style="padding:16px;text-align:center;color:var(--text-muted)">unavailable</div>';
    }
  }

  function wireNavbar() {
    const nav = document.querySelector('.nav');
    const toggle = document.querySelector('.nav-toggle');
    const navLinks = document.querySelector('.nav-links');

    if (toggle && navLinks) {
      toggle.addEventListener('click', () => {
        const expanded = toggle.getAttribute('aria-expanded') === 'true';
        toggle.setAttribute('aria-expanded', String(!expanded));
        navLinks.classList.toggle('nav-open');
      });
    }

    const handleScroll = () => {
      if (!nav) return;
      nav.classList.toggle('scrolled', window.scrollY > 50);
    };
    window.addEventListener('scroll', handleScroll, { passive: true });
    handleScroll();

    const sections = document.querySelectorAll('section[id]');
    const links = document.querySelectorAll('.nav-links a');
    if (sections.length && links.length) {
      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            const id = entry.target.getAttribute('id');
            links.forEach(link => {
              const href = link.getAttribute('href');
              link.classList.toggle('active', href && href.includes(id));
            });
          }
        });
      }, { threshold: 0.2, rootMargin: '-80px 0px -40% 0px' });
      sections.forEach(section => observer.observe(section));
    }
  }

  function wireFooter() {
    const yearEl = document.getElementById('current-year');
    if (yearEl) yearEl.textContent = new Date().getFullYear();
  }

  function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function (e) {
        const href = this.getAttribute('href');
        if (href === '#') return;
        const target = document.querySelector(href);
        if (target) {
          e.preventDefault();
          const top = target.getBoundingClientRect().top + window.pageYOffset - 80;
          window.scrollTo({ top, behavior: 'smooth' });
        }
      });
    });
  }

  function initReveal() {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.1, rootMargin: '0px 0px -60px 0px' });
    document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
  }

  function initCopyButtons() {
    document.querySelectorAll('.copy-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const block = btn.closest('.code-block');
        if (!block) return;
        const text = block.textContent.replace('Copy', '').trim();
        navigator.clipboard.writeText(text).then(() => {
          btn.classList.add('copied');
          btn.innerHTML = '<i class="ph ph-check" aria-hidden="true"></i> Copied';
          setTimeout(() => {
            btn.classList.remove('copied');
            btn.innerHTML = '<i class="ph ph-copy" aria-hidden="true"></i> Copy';
          }, 2000);
        }).catch(() => {
          btn.innerHTML = '<i class="ph ph-x" aria-hidden="true"></i> Error';
          setTimeout(() => {
            btn.innerHTML = '<i class="ph ph-copy" aria-hidden="true"></i> Copy';
          }, 1500);
        });
      });
    });
  }

  function init() {
    loadComponent('components/navbar.html', 'dynamic-nav', wireNavbar);
    loadComponent('components/footer.html', 'dynamic-footer', wireFooter);
    initSmoothScroll();
    initReveal();
    initCopyButtons();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
