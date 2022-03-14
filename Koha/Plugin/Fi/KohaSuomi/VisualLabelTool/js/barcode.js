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
        height: 35,
        width: 2,
        margin: 0,
      });
    },
  },
});

export default barcode;
