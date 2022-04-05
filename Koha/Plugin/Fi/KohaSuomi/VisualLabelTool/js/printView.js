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
                        <div class="print-row" :style="label.signum && label.type != 10 ? \'width:90%;\' : \'width:100%;\'">\
                            <div v-for="label in prints">\
                                <div :style="label.dimensions">\
                                    <div style="height: 100%; position:relative;" :style="test ? \'border: 1px solid;\' : \'\'">\
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
                                    <div style="height: 100%; position:relative; margin-left:2mm" :style="test ? \'border: 1px solid;\' : \'\'">\
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
});

export default printView;
