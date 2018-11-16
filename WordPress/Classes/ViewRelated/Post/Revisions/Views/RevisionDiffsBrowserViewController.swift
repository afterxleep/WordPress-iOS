import Gridicons

class RevisionBrowserState {
    let revisions: [Revision]
    var currentIndex: Int

    init(revisions: [Revision], currentIndex: Int) {
        self.revisions = revisions
        self.currentIndex = currentIndex
    }

    func currentRevision() -> Revision {
        return revisions[currentIndex]
    }
    func decreaseIndex() {
        currentIndex = max(currentIndex - 1, 0)
    }
    func increaseIndex() {
        currentIndex = min(currentIndex + 1, revisions.count)
    }
}

class RevisionDiffsBrowserViewController: UIViewController {
    var revisionState: RevisionBrowserState?
    var diffVC: RevisionDiffViewController?
    var operationVC: RevisionOperationViewController?
    @IBOutlet var revisionTitle: UILabel!
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var nextButton: UIButton!


    private lazy var doneBarButtonItem: UIBarButtonItem = {
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        doneItem.on() { [weak self] _ in
            self?.dismiss(animated: true)
        }
        doneItem.title = NSLocalizedString("Done", comment: "Label on button to dismiss revisions view")
        return doneItem
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavbarItems()
        setNextPreviousButtons()
        showRevision()
    }

    private func showRevision() {
        guard let revisionState = revisionState else {
            return
        }

        let revision = revisionState.currentRevision()
        diffVC?.revision = revision
        revisionTitle?.text = revision.revisionDate.mediumString()
        operationVC?.revision = revision

        updateNextPreviousButtons()
    }

    private func setNextPreviousButtons() {
        previousButton.setTitle("", for: .normal)
        previousButton.setImage(Gridicon.iconOfType(.chevronLeft).imageWithTintColor(WPStyleGuide.darkGrey()), for: .normal)
        previousButton.on(.touchUpInside) { [weak self] _ in
            self?.showPrevious()
        }

        nextButton.setTitle("", for: .normal)
        nextButton.setImage(Gridicon.iconOfType(.chevronRight).imageWithTintColor(WPStyleGuide.darkGrey()), for: .normal)
        nextButton.on(.touchUpInside) { [weak self] _ in
            self?.showNext()
        }
    }

    private func setupNavbarItems() {
        navigationItem.leftBarButtonItems = [doneBarButtonItem]
        navigationItem.title = NSLocalizedString("Revision", comment: "Title of the screen that shows the revisions.")
    }

    private func updateNextPreviousButtons() {
        guard let revisionState = revisionState else {
            return
        }
        previousButton.isHidden = revisionState.currentIndex == 0
        nextButton.isHidden = revisionState.currentIndex == revisionState.revisions.count - 1
    }

    private func showNext() {
        revisionState?.increaseIndex()
        showRevision()
    }

    private func showPrevious() {
        revisionState?.decreaseIndex()
        showRevision()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.destination {
        case let diffVC as RevisionDiffViewController:
            self.diffVC = diffVC
        case let operationVC as RevisionOperationViewController:
            self.operationVC = operationVC
        default:
            break
        }
    }
}
