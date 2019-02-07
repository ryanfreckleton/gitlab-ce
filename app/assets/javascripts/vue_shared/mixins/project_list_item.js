import sanitize from 'sanitize-html';
import _ from 'underscore';

export default {
  computed: {
    hasAvatar() {
      return _.isString(this.avatarUrl);
    },
    highlightedItemName() {
      if (this.matcher) {
        const matcherRegEx = new RegExp(this.matcher, 'gi');
        const matches = this.itemName.match(matcherRegEx);

        if (matches && matches.length > 0) {
          const bolded = this.itemName.replace(matches[0], `<b>${matches[0]}</b>`);
          return sanitize(bolded, { allowedTags: 'b' });
        }
      }

      return this.itemName;
    },

    /**
     * Smartly truncates item namespace by doing two things;
     * 1. Only include Group names in path by removing item name
     * 2. Only include first and last group names in the path
     *    when namespace has more than 2 groups present
     *
     * First part (removal of item name from namespace) can be
     * done from backend but doing so involves migration of
     * existing item namespaces which is not wise thing to do.
     */
    truncatedNamespace() {
      if (!this.namespace) {
        return null;
      }

      const namespaceArr = this.namespace.split(' / ');

      namespaceArr.splice(-1, 1);
      let namespace = namespaceArr.join(' / ');

      if (namespaceArr.length > 2) {
        namespace = `${namespaceArr[0]} / ... / ${namespaceArr.pop()}`;
      }

      return namespace;
    },
  },
};
