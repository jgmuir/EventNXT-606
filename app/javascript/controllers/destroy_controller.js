import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 'destroy' ];
  static values = { url: String };

  destroy() {
    if (this.destroyTargets.length > 0) {
      this.destroyTargets.forEach( elem => {
        if (elem.checked)
          fetch(`${this.urlValue}/${elem.value}`, {
            method: 'DELETE'
          }).then(response => this.indexController.query())
      })
    }
  }

  destroyByValue(e) {
    let elem = e.currentTarget;
    let resource;
    console.log(elem.value)
    console.log(elem.getAttribute('data-nxt-id'))
    if (elem.value) {
      resource = elem.value;
    } else if (elem.getAttribute('data-nxt-id')) {
      resource = elem.getAttribute('data-nxt-id');
    } else {
      return;
    }
    fetch(`${this.urlValue}/${resource}`, {
      method: 'DELETE'
    }).then(response => this.indexController.query())
  }

  get indexController() {
    return this.application.getControllerForElementAndIdentifier(this.element, "index")
  }
}