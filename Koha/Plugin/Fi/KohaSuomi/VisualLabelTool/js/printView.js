import barcode from './barcode.js';
const printView = Vue.component('print-view', {
  components: {
    barcode,
  },
  template:
      '<div class="print-row">\
          <div class="print-row" :style="labelWidth">\
              <div v-for="(label, index) in prints">\
                  <div :style="label.dimensions">\
                      <div style="height: 100%; position:relative; overflow: hidden" :style="test ? \'border: 1px solid;\' : \'\'">\
                          <span v-for="(field, index) in label.fields" :style="field.dimensions" style="position:absolute;">\
                              <span v-if="field.name == \'items.barcode\'"><barcode :value="field.value" :fontsize="field.dimensions.fontSize"></barcode></span>\
                              <span v-else :style="smallText(field.dimensions.fontSize) ? \'letter-spacing: 0.5px;\' : \'\'">{{field.value}}</span>\
                          </span>\
                      </div>\
                  </div>\
              </div>\
          </div>\
          <div v-if="label.signum" :class="[label.type == 10 ? \'print-row\' : \'\']">\
              <div v-for="(label, index) in prints">\
                  <div :style="label.signum.dimensions">\
                      <div style="height: 100%; position:relative;" :style="test ? \'border: 1px solid;\' : \'\'">\
                          <span v-for="(field, index) in label.signum.fields" :style="field.dimensions" style="position:absolute;">\
                              {{field.value}}\
                          </span>\
                      </div>\
                  </div>\
              </div>\
          </div>\
      </div>',
  props: ['label', 'prints', 'test'],
  data() {
    return {
      margins: {marginTop: localStorage.getItem('LabelToolTopMargin'), marginLeft: localStorage.getItem('LabelToolLeftMargin')},
    };
  },
  computed: {
    labelWidth: function () {
      let newwidth = parseInt(this.label.dimensions.width);
      let unit = this.label.dimensions.width.substr(
        newwidth.toString().length - this.label.dimensions.width.length
      );
      if (this.label.type != 'roll') {
        newwidth = newwidth * 2;
      }
      if (this.label.type == 'signum') {
        newwidth = '';
        unit = '';
      }
      newwidth = newwidth + unit;
      return { width: newwidth };
    },
  },
  methods: {
    calIndeces: function() {
      let pages = Math.ceil(this.prints.length / this.label.labelcount);
      let count = parseInt(this.label.labelcount)-1;
      let val = 0;
      for (let i = 0; i < pages; i++) {
        val = count == 0 ? i : val+count;
        this.indeces.push(val);
        
      }
    },
    pageBreak: function(index) {
      let match = false;
      this.indeces.forEach((ind) => {
        if (ind == index) {
          match = true;
        } 
      });
      return match;
    },
    smallText: function(size) {
      let spacing = false;
      if (parseInt(size) < 14) {
        spacing = true;
      }
      return spacing;
    }
  }
});

export default printView;
