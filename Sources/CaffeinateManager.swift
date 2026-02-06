import Foundation

protocol CaffeinateManagerDelegate: AnyObject {
    func caffeinateManagerDidStart(_ manager: CaffeinateManager)
    func caffeinateManagerDidStop(_ manager: CaffeinateManager)
    func caffeinateManager(_ manager: CaffeinateManager, didFailWithError error: Error)
}

class CaffeinateManager {
    weak var delegate: CaffeinateManagerDelegate?
    private(set) var process: Process?

    var isActive: Bool {
        return process?.isRunning ?? false
    }

    func start() {
        guard !isActive else { return }

        let newProcess = Process()
        newProcess.executableURL = URL(fileURLWithPath: Constants.CaffeinateProcess.executablePath)
        newProcess.arguments = Constants.CaffeinateProcess.arguments

        newProcess.terminationHandler = { [weak self] terminatedProcess in
            guard let self = self else { return }
            // Only notify if this is still our tracked process (unexpected termination)
            if self.process === terminatedProcess {
                self.process = nil
                DispatchQueue.main.async {
                    self.delegate?.caffeinateManagerDidStop(self)
                }
            }
        }

        do {
            try newProcess.run()
            process = newProcess
            delegate?.caffeinateManagerDidStart(self)
        } catch {
            delegate?.caffeinateManager(self, didFailWithError: error)
        }
    }

    func stop() {
        guard let runningProcess = process else { return }
        // Clear reference before terminating so terminationHandler knows it was intentional
        process = nil
        runningProcess.terminate()
        delegate?.caffeinateManagerDidStop(self)
    }

    func toggle() {
        if isActive {
            stop()
        } else {
            start()
        }
    }
}
