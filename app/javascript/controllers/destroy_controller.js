import { Controller } from "@hotwired/stimulus"
import IndexController from "./index_controller";

export default class extends Controller {
  static targets = [ 'destroy' ];
  static values = { url: String };

  destroy() {
    if (this.destroyTargets.length > 0) {
      this.destroyTargets.forEach( elem => {
        if (elem.checked)
          fetch(`${this.urlValue}/${elem.value}`, {
            method: 'DELETE'
          }).then(response => this.dispatch('deleted'))
      })
    }
  }

  destroyByValue(e) {
    let elem = e.currentTarget;
    let resource;
    if (elem.value && elem.value !== '') {
      resource = elem.value;
    } else if (elem.getAttribute('data-nxt-id')) {
      resource = elem.getAttribute('data-nxt-id');
    } else {
      return;
    }
    fetch(`${this.urlValue}/${resource}`, {
      method: 'DELETE'
    }).then(response => this.dispatch('deleted'))
  }
}