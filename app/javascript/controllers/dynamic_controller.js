import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  addFromTemplate({ params: { templateid, targetid }}) {
    console.log(templateid, targetid);
    let template = this.element.querySelector(`template#${templateid}`)
        .content.cloneNode(true);
    this.element.querySelector(`#${targetid}`).appendChild(template);
  }

  updateText(e) {
    e.currentTarget.textContent = e.params["text"];
  }

  disable(e) {
    e.currentTarget.disabled = true;
  }

  destroy() {
    this.element.remove();
  }
}