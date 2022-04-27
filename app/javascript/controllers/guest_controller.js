import IndexController from "controllers/index_controller";

export default class GuestController extends IndexController {
  static targets = [ 'tooltip' ];
  static values = { seaturl: String };

  query() {
    this.modifyTemplateWithSeats();
    super.query();
  }

  postProcess() {
    this.genTooltips();
    this.handleBookStatus();
    this.handleAddedBy();
  }

  genTooltips() {
    for (const dom of this.tooltipTargets) {
      if (dom.childNodes.length === 0) {
        dom.remove();
        continue;
      }

      //let tooltip = new bootstrap.Tooltip(dom, {boundary: document.body});
      dom.setAttribute('data-bs-toggle', 'tooltip');
      dom.setAttribute('data-bs-placement', 'top');
      dom.title = dom.textContent;
      dom.textContent = '';
    }
  }

  handleBookStatus() {
    for (const dom of this.element.querySelectorAll('.booked')) {
      if (dom.textContent === 'false')
        dom.remove();
      else {
        dom.textContent = '';
        dom.title = 'booked';
      }
    }
  }

  handleAddedBy() {
    for (const dom of this.element.querySelectorAll('.added_by')) {
      fetch(`/api/v1/users/${dom.textContent}`)
        .then(response => response.json())
        .then(data => {
          dom.textContent = `${data['first_name']} ${data['last_name']}`
        })
    }
  }

  modifyTemplateWithSeats() {
    console.log("HERE" + this.seaturlValue)
    fetch(`${this.seaturlValue}`)
      .then(response => response.json())
      .then(data => {
        let template = this.element.querySelector('template#allotments');
        let templateNode = template.content.cloneNode(true);

        let opts = [];
        for (const dat of data)
          opts.push(new Option(dat['category'], dat['id'], false, false));

        let selects = templateNode.querySelectorAll('select.guest-seat-alloc');
        for (const select of selects) {
          select.innerHTML = '';
          for (const opt of opts)
            select.add(opt);
        }

        console.log(templateNode.firstElementChild.outerHTML);
        template.innerHTML = templateNode.firstElementChild.outerHTML;
      });
  }

  get indexController() {
    return this.application.getControllerForElementAndIdentifier(this.element, "index")
  }
}