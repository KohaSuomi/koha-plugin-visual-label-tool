import { t } from './translations.js';
const errors = Vue.component('error-component', {
  template:
    '<div class="alert alert-danger" role="alert" v-if="errors.length">\
        <b>{{ t("Tapahtui virhe:") }}</b>\
        <ul class="text-danger">\
            <li v-for="error in errors">{{ error | errorMessage }}</li>\
        </ul>\
    </div>\
    ',
  props: ['errors'],
  filters: {
    errorMessage: function (error) {
      let errormessage = error.message;
      if (error.response.data.message) {
        errormessage = error.response.data.message;
      }
      return errormessage;
    },
    t // Make translation function available in template
  },
});

export default errors;
