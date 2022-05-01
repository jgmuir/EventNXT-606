import IndexController from "controllers/index_controller";

export default class EventController extends IndexController {
  static targets = [ 'add' ]

  preProcess() {
    this.addTmp = this.addTarget.cloneNode(true)
  }

  postProcess() {
    this.domTarget.append(this.addTmp)
  }

}