const barcode = Vue.component('barcode', {
  template: '<svg ref="barcode"></svg>',
  props: ['value', 'fontsize'],
  mounted() {
    this.init();
  },
  methods: {
    init() {
      JsBarcode(this.$refs.barcode, this.value, {
        fontSize: parseInt(this.fontsize),
        format: 'CODE39',
        height: 35,
        width: 1,
        margin: 0,
      });
    },
  },
});

export default barcode;
