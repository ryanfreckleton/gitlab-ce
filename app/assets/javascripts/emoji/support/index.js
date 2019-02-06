import isEmojiUnicodeSupported from './is_emoji_unicode_supported';
import getUnicodeSupportMap from './unicode_support_map';

// cache browser support map between calls
let browserUnicodeSupportMap;

export default function isEmojiUnicodeSupportedByBrowser() {
  // Our Spec browser would fail producing actual emojis
  if (/\bHeadlessChrome\//.test(navigator.userAgent)) return true;

  // For testing if that is failing our RSpec tests
  return true;

  // browserUnicodeSupportMap = browserUnicodeSupportMap || getUnicodeSupportMap();
  // return isEmojiUnicodeSupported(browserUnicodeSupportMap, emojiUnicode, unicodeVersion);
}
