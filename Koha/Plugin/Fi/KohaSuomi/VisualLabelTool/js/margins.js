import { t } from './translations.js';
const margins = Vue.component('margins-component', {
  template:
    '<div class="form-inline">\
      <div class="form-group mr-2" style="width:210px;">\
          <div class="input-group">\
          <div class="input-group-prepend">\
              <span class="input-group-text"><i class="fas fa-arrow-down" :title="t(\'Ylämarginaali\')"></i></span>\
          </div>\
          <input type="text" class="form-control " name="topMargin" :placeholder="t(\'Ylämarginaali(mm)\')" v-model="topMargin" @change="setTopMargin($event)"/>\
          </div>\
      </div>\
      <div class="form-group mr-2" style="width:225px;">\
          <div class="input-group">\
          <div class="input-group-prepend">\
              <span class="input-group-text"><i class="fas fa-arrow-right" :title="t(\'Vasen marginaali\')"></i></span>\
          </div>\
          <input type="text" class="form-control" name="leftMargin" :placeholder="t(\'Vasen marginaali(mm)\')" v-model="leftMargin" @change="setLeftMargin($event)"/>\
          </div>\
      </div>\
    </div>\
  ',
  data() {
    return {
      topMargin: localStorage.getItem('LabelToolTopMargin'),
      leftMargin: localStorage.getItem('LabelToolLeftMargin'),
    };
  },
  methods: {
    setTopMargin(e) {
      localStorage.setItem('LabelToolTopMargin', e.target.value);
    },
    setLeftMargin(e) {
      localStorage.setItem('LabelToolLeftMargin', e.target.value);
    },
    t // Make translation function available in template
  },
});

export default margins;
