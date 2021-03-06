//
//  ContainingViewController.swift
//  TestCollapsingHeader
//
//  Created by Samuel Shiffman on 9/25/20.
//

import UIKit

// MARK:- Containing ViewController
class ContainingViewController: UIViewController {
    
    // header view or container for header view
    @IBOutlet weak var headerView: UIView!

    // scroll view container
    @IBOutlet weak var containerView: UIView!

    // constrain the height of the headerView
    // in a more complex UI, use frame, let autolayout calculate based on subviews
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!

    // constraint between the top of headerView and the top of the screen
    @IBOutlet weak var headerViewTop: NSLayoutConstraint!

    // constraint between the top of the tableView container and the top of the screen
    // also used for the "collapsed" height of the headerView
    @IBOutlet weak var containerViewTop: NSLayoutConstraint!

    // how far the header view gets scrolled offscreen
    var maxScrollAmount: CGFloat {
        let expandedHeight = headerViewHeight.constant
        let collapsedHeight = containerViewTop.constant
        return expandedHeight - collapsedHeight
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scrollView = containerView.subviews.first as? UIScrollView {
            // adjust the scroll view's top inset to account for scrolling the header offscreen
            scrollView.contentInset = UIEdgeInsets(top: maxScrollAmount, left: 0, bottom: 0, right: 0)
        }

        if var scrollViewContained = children.first as? ScrollViewContained {
            scrollViewContained.scrollDelegate = self
        }
    }
}

// MARK:- ScrollViewContaining Delegate

extension ContainingViewController: ScrollViewContainingDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // need to adjust the content offset to account for the content inset
        // negative because we are moving the header offscreen
        let newTopConstraintConstant = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        headerViewTop.constant = min(0, max(-maxScrollAmount, newTopConstraintConstant))
        let isAtTop = headerViewTop.constant == -maxScrollAmount

        // handle changes for collapsed state
        scrollViewScrolled(scrollView, didScrollToTop: isAtTop)
    }

    func scrollViewScrolled(_ scrollView: UIScrollView, didScrollToTop isAtTop:Bool) {
        headerView.backgroundColor = isAtTop ? UIColor.green : UIColor.systemIndigo
    }
}

// MARK:- TableView Controller, ScrollViewContained

class TableViewController: UITableViewController,
                           ScrollViewContained {

    // used to connect the scrolling to the containing controller
    weak var scrollDelegate: ScrollViewContainingDelegate?

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // pass scroll events to the containing controller
        scrollDelegate?.scrollViewDidScroll(scrollView)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TVC
        cell.titleLabel.text = "\(indexPath.row)"
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

// MARK:- Protocols

protocol ScrollViewContainingDelegate: NSObject {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

protocol ScrollViewContained {
    var scrollDelegate: ScrollViewContainingDelegate? { get set }
}

// MARK:- TableView Cell
class TVC: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!

}

