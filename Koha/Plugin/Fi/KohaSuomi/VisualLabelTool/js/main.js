import barcode from './barcode.js';
const Multiselect = Vue.component(
  'vue-multiselect',
  window.VueMultiselect.default
);

new Vue({
  el: '#viewApp',
  components: {
    Multiselect,
    vuedraggable,
    barcode,
  },
  created() {
    this.fetchLabels();
  },
  data: {
    errors: [],
    savedLabels: [],
    items: [],
    prints: [],
    labels: [],
    label: null,
    showPrinting: false,
    printingType: [
      { name: 'Oma lista', value: 'list' },
      { name: 'Tänään vastaanotettu', value: 'received' },
    ],
    type: null,
  },
  methods: {
    fetchLabels() {
      axios
        .get('/api/v1/contrib/kohasuomi/labels')
        .then((response) => {
          this.savedLabels = response.data;
        })
        .catch((error) => {
          this.errors.push(error.response.data.message);
        });
    },
    fetchItems() {
      this.items = [];
      var searchParams = new URLSearchParams();
      searchParams.append('type', this.type.value);
      axios
        .get('/api/v1/contrib/kohasuomi/labels/items', { params: searchParams })
        .then((response) => {
          this.items = response.data;
        })
        .catch((error) => {
          this.errors.push(error.response.data.message);
        });
    },
    back() {
      this.showPrinting = false;
    },
    printLabels(e) {
      e.preventDefault();
      var searchParams = new URLSearchParams();
      searchParams.append('test', false);
      axios
        .post(
          '/api/v1/contrib/kohasuomi/labels/print/' + this.label.id,
          this.prints,
          {
            params: searchParams,
          }
        )
        .then((response) => {
          this.labels = response.data;
          this.showPrinting = true;
        })
        .catch((error) => {
          this.errors.push(error.response.data.message);
        });
    },
    print() {
      printJS({
        printable: 'printLabel',
        type: 'html',
        css: '/plugin/Koha/Plugin/Fi/KohaSuomi/VisualLabelTool/css/print.css',
      });
    },
    removeFromPrint(index) {
      this.prints.splice(index, 1);
    },
  },
});
