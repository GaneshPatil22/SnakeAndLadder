//
//  ViewController.swift
//  SnakeLadderGame
//
//  Created by Patil, Ganesh on 17/11/22.
//

import UIKit

class ViewController: UIViewController {

    let board: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    let newGameButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("New Game", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .gray
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 2
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(startNewGame), for: .touchUpInside)
        return btn
    }()

    let diceButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("0", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .gray
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 2
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(rollDice), for: .touchUpInside)
        return btn
    }()

    let dice = Dice()
    var player1: IndexPath = Helper.getIndexPath(from: 1)
    var player2: IndexPath = Helper.getIndexPath(from: 45)
    var gameVM: SnakeLadderViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.setUpDelegates()
    }

    private func setUpUI() {
        self.view.addSubview(board)
        self.view.addSubview(newGameButton)
        self.view.addSubview(diceButton)

        board.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        board.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        board.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        board.heightAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true

        newGameButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        newGameButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        newGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newGameButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        diceButton.bottomAnchor.constraint(equalTo: newGameButton.topAnchor, constant: -10).isActive = true
        diceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        diceButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        diceButton.widthAnchor.constraint(equalToConstant: 50).isActive = true

    }

    private func setUpDelegates() {
        self.board.register(BoardCell.self, forCellWithReuseIdentifier: "BOARDCELL")
        self.board.delegate = self
        self.board.dataSource = self
    }

    private func setUpBoard() {

    }

    @objc func rollDice() {
        let number = dice.roll(prev: Int((diceButton.titleLabel?.text ?? "0")) ?? 0)
        diceButton.setTitle("\(number)", for: .normal)
        var player1Number = Helper.getNumber(from: player1)
        player1Number += number

        player1Number = gameVM?.doesSnakeBite(number: player1Number) ?? player1Number
        player1Number = gameVM?.doesLadderClimb(number: player1Number) ?? player1Number
        if (player1Number <= 100) {
            player1 = Helper.getIndexPath(from: player1Number)
        }
        if (player1Number == 100) {
            view.backgroundColor = .green
        } else {
            view.backgroundColor = .white
        }

        board.reloadData()
    }

    @objc func startNewGame() {
        player1 = Helper.getIndexPath(from: 1)

        let snaks = [Position(top: 91, bottom: 50), Position(top: 86, bottom: 21), Position(top: 24, bottom: 1)]
        let ladders = [Position(top: 72, bottom: 11), Position(top: 66, bottom: 27), Position(top: 99, bottom: 23)]

        gameVM = SnakeLadderViewModel(numberOfPlayers: 1, snakeArray: snaks, ladderArray: ladders)


        for snak in snaks {
            let idx1 = Helper.getIndexPath(from: snak.top)
            let idx2 = Helper.getIndexPath(from: snak.bottom)

            let cell = board.cellForItem(at: idx1) as? BoardCell
            let endCell = board.cellForItem(at: idx2) as? BoardCell

            var start = cell?.frame.origin ?? CGPoint(x: 0, y: 0)
            start = CGPoint(x: start.x + ((cell?.frame.size.width ?? 0) / 2), y: start.y + ((cell?.frame.size.width ?? 0) / 2))

            var end = endCell?.frame.origin ?? CGPoint(x: 0, y: 0)
            end = CGPoint(x: end.x + ((endCell?.frame.size.width ?? 0) / 2), y: end.y + ((endCell?.frame.size.width ?? 0) / 2))


            self.drawLineFromPoint(start: start, toPoint: end, ofColor: .red, inView: board)
        }

        for ladder in ladders {
            let idx1 = Helper.getIndexPath(from: ladder.top)
            let idx2 = Helper.getIndexPath(from: ladder.bottom)

            let cell = board.cellForItem(at: idx1) as? BoardCell
            let endCell = board.cellForItem(at: idx2) as? BoardCell

            var start = cell?.frame.origin ?? CGPoint(x: 0, y: 0)
            start = CGPoint(x: start.x + ((cell?.frame.size.width ?? 0) / 2), y: start.y + ((cell?.frame.size.width ?? 0) / 2))

            var end = endCell?.frame.origin ?? CGPoint(x: 0, y: 0)
            end = CGPoint(x: end.x + ((endCell?.frame.size.width ?? 0) / 2), y: end.y + ((endCell?.frame.size.width ?? 0) / 2))


            self.drawLineFromPoint(start: start, toPoint: end, ofColor: .green, inView: board)
        }
        board.reloadData()
    }

    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view:UIView) {

        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = 5.0

        view.layer.addSublayer(shapeLayer)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BOARDCELL", for: indexPath) as? BoardCell else {
            return UICollectionViewCell()
        }
        let number = Helper.getNumber(from: indexPath)
        cell.setNumber(number: number)
        if indexPath == player1 {
            cell.numberLabel.backgroundColor = .systemBlue
        } else if indexPath == player2 {
            cell.numberLabel.backgroundColor = .purple
        } else {
            cell.numberLabel.backgroundColor = .clear
        }

        if (gameVM?.snakesIndex.contains(indexPath) ?? false) {
            cell.backgroundColor = .red
        } else if (gameVM?.laddersIndex.contains(indexPath) ?? false) {
            cell.backgroundColor = .green
        } else {
            cell.backgroundColor = .clear
        }
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width) / 10
        return CGSize(width: width, height: width)
    }


}

class BoardCell: UICollectionViewCell {

    let numberLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.layer.borderColor = UIColor.black.cgColor
        lbl.layer.borderWidth = 1
        lbl.layer.cornerRadius = 5
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialSetUP()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialSetUP()
    }

    private func initialSetUP() {
        addSubview(numberLabel)

        numberLabel.frame = bounds
    }

    func setNumber(number: Int) {
        self.numberLabel.text = "\(number)"
    }
}

struct Helper {
    static func getIndexPath(from number: Int) -> IndexPath {
        let num = number - 1
        var section: Int = num / 10
        var row: Int = num % 10

        section = 9 - section
        if section % 2 != 0 {

        } else {
            row = 9 - row
        }
        return IndexPath(row: row, section: section)
    }

    static func getNumber(from indexPath: IndexPath) -> Int {
        var row = 0
        if (indexPath.section % 2 == 0) {
            row = (10 - indexPath.row)
        } else {
            row = (indexPath.row + 1)
        }
        let number = ((9 - indexPath.section) * 10) + row
        return number
    }
}

struct Position {
    let top: Int
    let bottom: Int
}

struct SnakeLadderViewModel {
    let numberOfPlayers: Int
    let snakeArray: [Position]
    let ladderArray: [Position]
    var snakesIndex: [IndexPath] = []
    var laddersIndex: [IndexPath] = []

    init(numberOfPlayers: Int, snakeArray: [Position], ladderArray: [Position]) {
        self.numberOfPlayers = numberOfPlayers
        self.snakeArray = snakeArray
        self.ladderArray = ladderArray

        for snake in snakeArray {
            let idx1 = Helper.getIndexPath(from: snake.top)
            let idx2 = Helper.getIndexPath(from: snake.bottom)
            snakesIndex.append(idx1)
            snakesIndex.append(idx2)
        }

        for ladder in ladderArray {
            let idx1 = Helper.getIndexPath(from: ladder.top)
            let idx2 = Helper.getIndexPath(from: ladder.bottom)
            laddersIndex.append(idx1)
            laddersIndex.append(idx2)
        }
    }

    func doesSnakeBite(number: Int) -> Int {
        for snake in snakeArray {
            if (snake.top == number) {
                return snake.bottom
            }
        }
        return number
    }

    func doesLadderClimb(number: Int) -> Int {
        for ladder in ladderArray {
            if (ladder.bottom == number) {
                return ladder.top
            }
        }
        return number
    }
}

struct Dice {
    func roll(prev: Int) -> Int {
        var current = [1, 2, 3, 4, 5, 6].randomElement()!
        while (prev == current) {
            current = [1, 2, 3, 4, 5, 6].randomElement()!
        }
        return current
    }
}

