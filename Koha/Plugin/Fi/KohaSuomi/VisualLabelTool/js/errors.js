import { t } from './translations.js';
const errors = Vue.component('error-component', {
  template:
    '<div class="alert alert-danger" role="alert" v-if="errors.length">\
        <b>{{ t("Tapahtui virhe") }}</b>\
        <ul class="text-danger">\
            <li v-for="error in errors">{{ error | errorMessage }}</li>\
        </ul>\
    </div>\
    ',
  props: ['errors'],
  filters: {
    errorMessage: function (error) {
      // Handle string errors
      if (typeof error === 'string') {
        return error;
      }
      
      // Handle structured error objects
      let errormessage = error.message || 'Unknown error';
      
      // Check for response data message or error
      if (error.response && error.response.data) {
        errormessage = error.response.data.message || error.response.data.error || errormessage;
      }
      
      return errormessage;
    }
  },
  methods: {
    t // Translation method
  }
});

export default errors;
