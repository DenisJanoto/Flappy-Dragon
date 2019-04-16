//
//  GameScene.swift
//  FlappyDragon
//
//  Created by Denis Janoto on 03/04/2019.
//  Copyright © 2019 Denis Janoto. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var floor:SKSpriteNode!
    var intro:SKSpriteNode!
    var player:SKSpriteNode!
    var scoreLabel:SKLabelNode!
    var gameArea:CGFloat = 410.0
    var velocity:Double = 100.0
    var score:Int = 0
    var flyForce:CGFloat = 30.0
    var gameFinished = false
    var gameStarted = false
    var restart = false
    var playerCategory:UInt32 = 1
    var enemyCategory:UInt32 = 2
    var scoreCategory:UInt32 = 4
    var timer:Timer!
    weak var gameViewController:GameViewController?
    let gameOverSound = SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false)
    let scoreSound = SKAction.playSoundFileNamed("score.mp3", waitForCompletion: false)
    
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        addBackGround()
        addFloor()
        addIntro()
        addPlayer()
        addMove()
    }
    
    
    //ADD BACKGROUND
    func addBackGround(){
        let background = SKSpriteNode(imageNamed: "background") //IMAGEM
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)//POSICIONAMENTO DA IMAGEM
        addChild(background)//ADICIONAR A IMAGEM
        background.zPosition = 0 //NUMERO ACIMA DE 0 É ACIMA DO BACKGROUND
    }
    
    //ADD FLOOR
    func addFloor(){
        floor = SKSpriteNode(imageNamed: "floor")
        floor.zPosition = 2
        floor.position = CGPoint(x: floor.size.width/2, y: size.height - gameArea - floor.size.height/2)
        addChild(floor)
        
        //ADICIONAR COLISÃO NO CHÃO
        let invisibleFloor = SKNode()
        invisibleFloor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 1))
        invisibleFloor.physicsBody?.isDynamic = false
        invisibleFloor.position = CGPoint(x: size.width/2, y: size.height - gameArea)
        invisibleFloor.zPosition = 2
        addChild(invisibleFloor)
        
        //ADICIONAR COLISÃO NO CEU
        let invisibleRoof = SKNode()
        invisibleRoof.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 1))
        invisibleRoof.physicsBody?.isDynamic = false
        invisibleRoof.physicsBody?.categoryBitMask = enemyCategory
        invisibleRoof.physicsBody?.categoryBitMask = playerCategory
        invisibleRoof.position = CGPoint(x: size.width/2, y: size.height)
        invisibleRoof.zPosition = 2
        addChild(invisibleRoof)
        
    }
    
    //ADD INTRO
    func addIntro(){
        intro = SKSpriteNode(imageNamed: "intro")
        intro.zPosition = 3
        intro.position = CGPoint(x: size.width/2, y: size.height - 210)
        addChild(intro)
    }
    
    //ADD PLAYER
    func addPlayer(){
        player = SKSpriteNode(imageNamed: "player1")
        player.zPosition = 4
        player.position = CGPoint(x: 60, y: size.height - gameArea/2)
        
        
        //ANIMAÇÃO - 1 A 4 POIS POSSUI 4 IMAGENS PARA A ANIMAÇAO
        var playerTextures = [SKTexture]()
        for i in 1...4{
            playerTextures.append(SKTexture(imageNamed: "player\(i)"))
        }
        
        //ANIMAR COM TEMPO PADRÃO DE 0.09 E FICAR EM LOOP (REPEATACTION)
        let animationAction = SKAction.animate(with: playerTextures, timePerFrame: 0.09)
        let repeatAction = SKAction.repeatForever(animationAction)
        player.run(repeatAction)
        addChild(player)
    }
    
    
    //ADDMOVE
    func addMove(){
        //FLOOR ANIMATION
        let duration = Double(floor.size.width/2)/velocity
        let moveFloorAction = SKAction.moveBy(x: -floor.size.width/2, y: 0, duration: duration)
        let resetXAction = SKAction.moveBy(x: floor.size.width/2, y: 0, duration: 0)
        let sequenceAction = SKAction.sequence([moveFloorAction,resetXAction])//EXECUTAR NA SEQUENCIA
        let repeatAction = SKAction.repeatForever(sequenceAction)
        floor.run(repeatAction)
        
    }
    
    //ADD PLACAR
    func addScore(){
        scoreLabel = SKLabelNode(fontNamed: "chalkduster")
        scoreLabel.fontSize = 94
        scoreLabel.text = "\(score)"
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height-100)
        scoreLabel.alpha  = 0.8
        scoreLabel.zPosition = 5
        addChild(scoreLabel)
    }
    
    
    //INIMIGOS
    func spawEnemies(){
        let initialPosition = CGFloat(arc4random_uniform(132)+74)
        let enemyNumber = Int(arc4random_uniform(4)+1)
        let enemiesDistance = self.player.size.height * 2.5
        
        let enemyTop = SKSpriteNode(imageNamed: "enemytop\(enemyNumber)")
        let enemyWidth = enemyTop.size.width
        let enemyHeidth = enemyTop.size.height
        
        enemyTop.position = CGPoint(x: size.width + enemyWidth/2, y: size.height - initialPosition + enemyHeidth/2)
        
        enemyTop.zPosition = 1
        enemyTop.physicsBody = SKPhysicsBody(rectangleOf: enemyTop.size)
        enemyTop.physicsBody?.isDynamic = false
        enemyTop.physicsBody?.categoryBitMask = enemyCategory
        enemyTop.physicsBody?.contactTestBitMask = playerCategory
        
        
        let enemyBotton = SKSpriteNode(imageNamed: "enemybottom\(enemyNumber)")
        enemyBotton.position = CGPoint(x: size.width + enemyWidth/2, y: enemyTop.position.y - enemyTop.size.height - enemiesDistance)
        
        enemyBotton.zPosition = 1
        enemyBotton.physicsBody = SKPhysicsBody(rectangleOf: enemyBotton.size)
        enemyBotton.physicsBody?.isDynamic = false
        enemyBotton.physicsBody?.categoryBitMask = enemyCategory
        enemyBotton.physicsBody?.contactTestBitMask = playerCategory
        
        let laser = SKNode()
        laser.position = CGPoint(x: enemyTop.position.x + enemyWidth/2, y: enemyTop.position.y - enemyTop.size.height/2 - enemiesDistance/2)
        
        laser.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: enemiesDistance))
        laser.physicsBody?.isDynamic = false
        laser.physicsBody?.categoryBitMask = scoreCategory
        
        
        let distance = size.width + enemyWidth
        let duration = Double(distance)/velocity
        let moveAction = SKAction.moveBy(x: -distance, y: 0, duration: duration)
        let removeAction = SKAction.removeFromParent()
        let sequenceAction = SKAction.sequence([moveAction,removeAction])
        
        enemyTop.run(sequenceAction)
        enemyBotton.run(sequenceAction)
        laser.run(sequenceAction)
        
        addChild(enemyTop)
        addChild(enemyBotton)
        addChild(laser)
    }
    
    //GAME OVER
    func gameOver(){
        timer.invalidate()
        player.zRotation = 0
        player.texture = SKTexture(imageNamed: "playerDead")
        for node in self.children{
            node.removeAllActions()
        }
        player.physicsBody?.isDynamic = false
        gameFinished = true
        gameStarted = false
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
            let gameOverLabel = SKLabelNode(fontNamed: "chalkduster")
            gameOverLabel.fontColor = .red
            gameOverLabel.fontSize = 40
            gameOverLabel.text = "Game Over"
            gameOverLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
            gameOverLabel.zPosition = 5
            self.addChild(gameOverLabel)
            self.restart = true
        }
        
        
    }
    
    
    //TOCAR NA TELA
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameFinished{
            if !gameStarted{
                //REMOVE A TELA DE INTRO
                intro.removeFromParent()
                addScore()
                
                //APLICA A FISICA NO DRAGAO(SUBIR E DESCER)
                player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2-10)
                player.physicsBody?.isDynamic = true
                player.physicsBody?.allowsRotation = true
                player.physicsBody?.applyForce(CGVector(dx: 0, dy: flyForce))
                player.physicsBody?.categoryBitMask = playerCategory
                player.physicsBody?.contactTestBitMask = scoreCategory
                player.physicsBody?.collisionBitMask = enemyCategory
                
                
                
                gameStarted = true
                
                timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { (timer) in
                    self.spawEnemies()
                }
            }else{
                player.physicsBody?.velocity = CGVector.zero
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: flyForce))
            }
        }else{
            if restart{
                restart = false
                gameViewController?.presentScene()
            }
        }
        
    }
    
    //METODO EXECUTADO A TODO O MOMENTO (30FPS - METODO EXECUTA 30 VEZES)
    override func update(_ currentTime: TimeInterval) {
        if gameStarted{
            //INCLINA O DRAGÃO PARA CIMA AO TOCAR NA TELA E PARA BAIXO AO SOLTAR
            let yVelocity = (player.physicsBody?.velocity.dy)! * 0.001 as CGFloat
            player.zRotation = yVelocity
        }
        
    }
}

extension GameScene:SKPhysicsContactDelegate{
    //DISPARADO AO HAVER CONTATO ENTRE OS OBJETOS
    func didBegin(_ contact: SKPhysicsContact) {
        if gameStarted{
            if contact.bodyA.categoryBitMask == scoreCategory || contact.bodyB.categoryBitMask == scoreCategory{
                score+=1
                scoreLabel.text = "\(score)"
                run(scoreSound)
            }else if contact.bodyA.categoryBitMask == enemyCategory || contact.bodyB.categoryBitMask == enemyCategory{
               gameOver()
                run(gameOverSound)
            }
        }
    }
}
