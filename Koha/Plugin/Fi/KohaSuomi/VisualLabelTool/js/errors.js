const errors = Vue.component('error-component', {
  template:
    '<div class="alert alert-danger" role="alert" v-if="errors.length">\
        <b>Tapahtui virhe:</b>\
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
  },
});

export default errors;
