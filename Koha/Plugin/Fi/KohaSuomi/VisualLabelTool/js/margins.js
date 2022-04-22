const margins = Vue.component('margins-component', {
  template:
    '<div class="form-inline">\
      <div class="form-group mr-2" style="width:120px;">\
          <div class="input-group">\
          <div class="input-group-prepend">\
              <span class="input-group-text"><i class="fas fa-arrow-down" title="Ylämarginaali"></i></span>\
          </div>\
          <input type="text" class="form-control " name="topMargin" v-model="topMargin" @change="setTopMargin($event)"/>\
          </div>\
      </div>\
      <div class="form-group mr-2" style="width:120px;">\
          <div class="input-group">\
          <div class="input-group-prepend">\
              <span class="input-group-text"><i class="fas fa-arrow-right" title="Vasen marginaali"></i></span>\
          </div>\
          <input type="text" class="form-control" name="leftMargin" v-model="leftMargin" @change="setLeftMargin($event)"/>\
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
  },
});

export default margins;
