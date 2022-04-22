import printView from './printView.js';
import margins from './margins.js';
const Multiselect = Vue.component(
  'vue-multiselect',
  window.VueMultiselect.default
);

new Vue({
  el: '#viewApp',
  components: {
    Multiselect,
    printView,
    margins,
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
      { name: 'Oma tulostusjono', value: 'list' },
      { name: 'Tänään vastaanotettu', value: 'received' },
      { name: 'Itse tulostetut', value: 'printed' },
    ],
    type: null,
    barcode: '',
    topMargin: 0,
    leftMargin: 0,
  },
  computed: {
    pageMargins: function () {
      return (
        '@page {margin-top: ' +
        this.topMargin +
        '; margin-left: ' +
        this.leftMargin +
        ';}'
      );
    },
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
        .get('/api/v1/contrib/kohasuomi/labels/print/queue', {
          params: searchParams,
        })
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
      this.topMargin = localStorage.getItem('LabelToolTopMargin')
        ? localStorage.getItem('LabelToolTopMargin')
        : 0;
      this.leftMargin = localStorage.getItem('LabelToolLeftMargin')
        ? localStorage.getItem('LabelToolLeftMargin')
        : 0;
      printJS({
        printable: 'printLabel',
        onPrintDialogClose: () => {
          this.updatePrintQueue();
        },
        type: 'html',
        css: '/plugin/Koha/Plugin/Fi/KohaSuomi/VisualLabelTool/css/print.css',
        style: [this.pageMargins],
      });
    },
    removeFromPrint(index) {
      this.prints.splice(index, 1);
    },
    removeFromItems(index) {
      if (
        confirm('Haluatko varmasti poistaa niteen ' + this.items[index].barcode)
      ) {
        axios
          .delete(
            '/api/v1/contrib/kohasuomi/labels/print/queue/' +
              this.items[index].queue_id
          )
          .then(() => {
            this.items.splice(index, 1);
          })
          .catch((error) => {
            this.errors.push(error.response.data.message);
          });
      }
    },
    addToPrints(index) {
      if (index >= 0) {
        this.prints.push(this.items[index]);
      } else {
        this.items.forEach((element) => {
          this.prints.push(element);
        });
      }
    },
    clearPrints() {
      this.prints = [];
    },
    setBarcode() {
      let element = { barcode: this.barcode };
      this.prints.push(element);
      this.barcode = '';
    },
    async updatePrintQueue() {
      const promises = [];
      this.prints.forEach((element) => {
        promises.push(
          axios
            .put('/api/v1/contrib/kohasuomi/labels/print/queue', {
              itemnumber: element.itemnumber,
              printed: 1,
              queue_id: element.queue_id,
            })
            .then(() => {})
            .catch((error) => {
              this.errors.push(error.response.data.message);
            })
        );
      });
      await Promise.all(promises).then(() => {
        this.clearPrints();
      });
    },
  },
});
