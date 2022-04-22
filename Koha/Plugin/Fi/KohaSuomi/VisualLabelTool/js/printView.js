import barcode from './barcode.js';
const printView = Vue.component('print-view', {
  components: {
    barcode,
  },
  template:
    '<div class="flex-row">\
            <div class="d-flex justify-content-center pb-2">\
                <div id="printLabel">\
                    <div class="print-row" :class="[label.type == \'roll\' ? \'roll-width\' : \'a4-width\']">\
                        <div class="print-row" :style="labelWidth">\
                            <div v-for="label in prints">\
                                <div :style="label.dimensions">\
                                    <div style="height: 100%; position:relative; white-space: nowrap; overflow: hidden" :style="test ? \'border: 1px solid;\' : \'\'">\
                                        <span v-for="(field, index) in label.fields" :style="field.dimensions" style="position:absolute;">\
                                            <span v-if="field.name == \'items.barcode\'"><barcode :value="field.value" :fontsize="field.dimensions.fontSize"></barcode></span>\
                                            <span v-else>{{field.value}}</span>\
                                        </span>\
                                    </div>\
                                </div>\
                            </div>\
                        </div>\
                        <div v-if="label.signum" :class="[label.type == 10 ? \'print-row\' : \'\']">\
                            <div v-for="label in prints">\
                                <div :style="label.signum.dimensions">\
                                    <div style="height: 100%; position:relative;" :style="test ? \'border: 1px solid;\' : \'\'">\
                                        <span v-for="(field, index) in label.signum.fields" :style="field.dimensions" style="position:absolute;">\
                                            {{field.value}}\
                                        </span>\
                                    </div>\
                                </div>\
                            </div>\
                        </div>\
                    </div>\
                </div>\
            </div>\
        </div>',
  props: ['label', 'prints', 'test'],
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
});

export default printView;
