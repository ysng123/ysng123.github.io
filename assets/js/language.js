(function () {
  'use strict';

  var storageKey = 'profile-language';
  var controls = document.querySelector('.language-switch');
  if (!controls) return;

  // Translations are trusted, authored HTML in the page, never user input.
  var content = Array.prototype.map.call(document.querySelectorAll('[data-zh]'), function (element) {
    return { element: element, en: element.innerHTML, zh: element.getAttribute('data-zh') };
  });
  var attributes = [];
  ['aria-label', 'alt', 'title'].forEach(function (attribute) {
    Array.prototype.forEach.call(document.querySelectorAll('[data-zh-' + attribute + ']'), function (element) {
      attributes.push({ element: element, name: attribute, en: element.getAttribute(attribute), zh: element.getAttribute('data-zh-' + attribute) });
    });
  });
  var englishTitle = document.title;
  var buttons = controls.querySelectorAll('[data-language]');

  function setLanguage(language) {
    var chinese = language === 'zh';
    document.documentElement.lang = chinese ? 'zh-CN' : 'en';
    document.title = chinese ? englishTitle.replace('Haoyang Tong', '童昊阳') : englishTitle;
    content.forEach(function (item) { item.element.innerHTML = chinese ? item.zh : item.en; });
    attributes.forEach(function (item) { item.element.setAttribute(item.name, chinese ? item.zh : item.en); });
    Array.prototype.forEach.call(buttons, function (button) {
      button.setAttribute('aria-pressed', String(button.getAttribute('data-language') === language));
    });
  }

  var initialLanguage = 'en';
  try {
    if (window.localStorage.getItem(storageKey) === 'zh') initialLanguage = 'zh';
  } catch (error) { /* Storage may be disabled; switching still works. */ }
  setLanguage(initialLanguage);
  controls.hidden = false;

  Array.prototype.forEach.call(buttons, function (button) {
    button.addEventListener('click', function () {
      var language = button.getAttribute('data-language');
      setLanguage(language);
      try { window.localStorage.setItem(storageKey, language); } catch (error) { /* Optional persistence. */ }
    });
  });
}());
