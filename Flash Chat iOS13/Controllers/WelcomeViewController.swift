import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var charIndex = 0.0
        titleLabel.text = ""
        titleLabel.adjustsFontSizeToFitWidth = true
        
        for letter in K.appTitle {
            Timer.scheduledTimer(withTimeInterval: (0.1 * charIndex), repeats: false) { timer in
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1
        }
    }
}
