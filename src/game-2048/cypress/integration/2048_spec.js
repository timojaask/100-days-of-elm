const b = (row0, row1, row2, row3) => {
  return `${row0}_${row1}_${row2}_${row3}`
}

const wonGameConfiguration = b('2048_2_0_0', '0_0_0_0', '0_0_0_0', '0_0_0_0')
const lostGameConfiguration = b('2_4_8_16', '4_8_16_32', '8_16_32_64', '16_32_64_128')

const visitBoardConfig = boardConfig => {
  cy.visit(`/?board=${boardConfig}`)
}

const expectToHaveOneValueCell = () => {
  cy.get('.boardCell--value')
    .should(($cells) => {
      expect($cells).to.have.length(1)
      expect($cells).to.contain('2')
    })
}

const expectToHave15EmptyCells = () => {
  cy.get('.boardCell--empty')
    .should(($cells) => {
      expect($cells).to.have.length(15)
      expect($cells).to.contain('0')
    })
}

const expectBoardToBe = boardConfig => {
  const expectedValues = boardConfig.split('_')
  cy.get('.boardCell span').each(($span, index) => {
    const text = $span.text()
    expect(text).to.equal(expectedValues[index])
  })
}

const expectToNotHaveWonLostMessages = () => {
  cy.get('span').filter('.wonMessage').should('have.length', 0)
  cy.get('span').filter('.lostMessage').should('have.length', 0)
}

const expectToHaveControls = () => {
  cy.get('.controls')
}

const expectNewGameState = () => {
  expectToNotHaveWonLostMessages()
  expectToHaveControls()
  expectToHaveOneValueCell()
  expectToHave15EmptyCells()
}

describe('new board', () => {
  beforeEach(() => {
    cy.visit('/')
  })
  it('should have 4 rows and 4 cells per row', () => {
    cy.get('.board .boardRow').should('have.length', 4)
      .each(($row) => {
        cy.wrap($row).within(() => {
          cy.get('.boardCell').should('have.length', 4)
        })
      })
  })

  it('should have just one cell with a value of 2', () => {
    expectToHaveOneValueCell()
  })

  it('should have 15 cells with value 0', () => {
    expectToHave15EmptyCells()
  })

  it('should not have lost or won messages', () => {
    expectToNotHaveWonLostMessages()
  })

  it('should have controls visible', () => {
    expectToHaveControls()
  })
})

describe('board with query', () => {
  it('should be new board when a value in query is invalid', () => {
    visitBoardConfig(b('3_8_8_8', '8_8_8_8', '8_8_8_8', '8_8_8_8'))
    expectNewGameState()
  })

  it('should be new board when the number of values is invalid', () => {
    visitBoardConfig('8_8_8_8_8_8_8_8_8_8')
    expectNewGameState()
  })

  it('should render a specified board when query is valid', () => {
    const boardConfig = b('0_2_4_8', '16_32_64_128', '256_512_1024_2', '2_2_2_2')
    visitBoardConfig(boardConfig)
    expectBoardToBe(boardConfig)
  })
})

describe('moving', () => {
  const DIR_LEFT = 0
  const DIR_RIGHT = 1
  const DIR_UP = 2
  const DIR_DOWN = 3

  const allDirections = [DIR_LEFT, DIR_RIGHT, DIR_UP, DIR_DOWN]

  const clickButton = dir => {
    let button = ''
    switch (dir) {
      case DIR_LEFT: button = '.buttonLeft'; break;
      case DIR_RIGHT: button = '.buttonRight'; break;
      case DIR_UP: button = '.buttonUp'; break;
      case DIR_DOWN: button = '.buttonDown'; break;
    }
    cy.get(button).click()
  }

  it('should add a new value to the board', () => {
    allDirections.forEach(dir => {
      visitBoardConfig(b('0_0_0_0', '0_2_0_0', '0_0_0_0', '0_0_0_0'))
      clickButton(dir)
      cy.get('.boardCell--value').should('have.length', 2)
    })
  })

  it('should not add new value when move has no effect', () => {
    allDirections.forEach(dir => {
      let board = ''
      switch (dir) {
        case DIR_LEFT: board = b('2_0_0_0', '0_0_0_0', '0_0_0_0', '0_0_0_0'); break;
        case DIR_RIGHT: board = b('0_0_0_2', '0_0_0_0', '0_0_0_0', '0_0_0_0'); break;
        case DIR_UP: board = b('0_2_0_0', '0_0_0_0', '0_0_0_0', '0_0_0_0'); break;
        case DIR_DOWN: board = b('0_0_0_0', '0_0_0_0', '0_0_0_0', '0_0_2_0'); break;
      }
      visitBoardConfig(board)
      clickButton(dir)
      cy.get('.boardCell--value').should('have.length', 1)
    })
  })

  it('should move a cell and stop at wall', () => {
    allDirections.forEach(dir => {
      let board = '', targetIdx = 0
      switch (dir) {
        case DIR_LEFT:
          board = b('0_0_0_0', '0_0_8_0', '0_0_0_0', '0_0_0_0');
          targetIdx = 4;
          break;
        case DIR_RIGHT:
          board = b('0_0_0_0', '0_8_0_0', '0_0_0_0', '0_0_0_0');
          targetIdx = 7;
          break;
        case DIR_UP:
          board = b('0_0_0_0', '0_0_0_0', '0_8_0_0', '0_0_0_0');
          targetIdx = 1;
          break;
        case DIR_DOWN:
          board = b('0_0_0_0', '0_8_0_0', '0_0_0_0', '0_0_0_0');
          targetIdx = 13;
          break;
      }
      visitBoardConfig(board)
      clickButton(dir)
      cy.get('.boardCell').eq(targetIdx).should('contain', '8')
    })
  })

  it('should move cells, but not merge when different values', () => {
    allDirections.forEach(dir => {
      let board = '', targetIdx1 = 0, targetIdx2 = 0
      switch (dir) {
        case DIR_LEFT:
          board = b('0_0_0_0', '0_4_0_8', '0_0_0_0', '0_0_0_0');
          targetIdx1 = 4;
          targetIdx2 = 5;
          break;
        case DIR_RIGHT:
          board = b('0_0_0_0', '8_0_4_0', '0_0_0_0', '0_0_0_0');
          targetIdx1 = 7;
          targetIdx2 = 6;
          break;
        case DIR_UP:
          board = b('0_0_0_0', '0_4_0_0', '0_0_0_0', '0_8_0_0');
          targetIdx1 = 1;
          targetIdx2 = 5;
          break;
        case DIR_DOWN:
          board = b('0_8_0_0', '0_0_0_0', '0_4_0_0', '0_0_0_0');
          targetIdx1 = 13;
          targetIdx2 = 9;
          break;
      }
      visitBoardConfig(board)
      clickButton(dir)
      cy.get('.boardCell').eq(targetIdx1).should('contain', '4')
      cy.get('.boardCell').eq(targetIdx2).should('contain', '8')
    })
  })

  it('should merge colliding cells #1', () => {
    allDirections.forEach(dir => {
      let board = '', targetIdx = 0
      switch (dir) {
        case DIR_LEFT:
          board = b('2_0_2_0', '0_0_0_0', '0_0_0_0', '0_0_0_0');
          targetIdx = 0;
          break;
        case DIR_RIGHT:
          board = b('0_2_0_2', '0_0_0_0', '0_0_0_0', '0_0_0_0');
          targetIdx = 3;
          break;
        case DIR_UP:
          board = b('0_2_0_0', '0_0_0_0', '0_2_0_0', '0_0_0_0');
          targetIdx = 1;
          break;
        case DIR_DOWN:
          board = b('0_0_0_0', '0_2_0_0', '0_0_0_0', '0_2_0_0');
          targetIdx = 13;
          break;
      }
      visitBoardConfig(board)
      clickButton(dir)
      cy.get('.boardCell').eq(targetIdx).should('contain', '4')
      cy.get('.boardCell--value').should('have.length', 2)
    })
  })

  it('should merge colliding cells #2', () => {
    allDirections.forEach(dir => {
      let board = '', targetIdx = 0
      switch (dir) {
        case DIR_LEFT:
          board = b('0_2_2_0', '0_0_0_0', '0_0_0_0', '0_0_0_0');
          targetIdx = 0;
          break;
        case DIR_RIGHT:
          board = b('0_2_2_0', '0_0_0_0', '0_0_0_0', '0_0_0_0');
          targetIdx = 3;
          break;
        case DIR_UP:
          board = b('0_0_0_0', '0_2_0_0', '0_2_0_0', '0_0_0_0');
          targetIdx = 1;
          break;
        case DIR_DOWN:
          board = b('0_0_0_0', '0_2_0_0', '0_2_0_0', '0_0_0_0');
          targetIdx = 13;
          break;
      }
      visitBoardConfig(board)
      clickButton(dir)
      cy.get('.boardCell').eq(targetIdx).should('contain', '4')
      cy.get('.boardCell--value').should('have.length', 2)
    })
  })

  it('should merge colliding cells #3', () => {
    allDirections.forEach(dir => {
      let board = '', targetIdx1 = 0, targetIdx2 = 0
      switch (dir) {
        case DIR_LEFT:
          board = b('2_2_2_2', '0_0_0_0', '0_0_0_0', '0_0_0_0');
          targetIdx1 = 0;
          targetIdx2 = 1;
          break;
        case DIR_RIGHT:
          board = b('2_2_2_2', '0_0_0_0', '0_0_0_0', '0_0_0_0');
          targetIdx1 = 3;
          targetIdx2 = 2;
          break;
        case DIR_UP:
          board = b('0_2_0_0', '0_2_0_0', '0_2_0_0', '0_2_0_0');
          targetIdx1 = 1;
          targetIdx2 = 5;
          break;
        case DIR_DOWN:
          board = b('0_2_0_0', '0_2_0_0', '0_2_0_0', '0_2_0_0');
          targetIdx1 = 13;
          targetIdx2 = 9;
          break;
      }
      visitBoardConfig(board)
      clickButton(dir)
      cy.get('.boardCell').eq(targetIdx1).should('contain', '4')
      cy.get('.boardCell').eq(targetIdx2).should('contain', '4')
      cy.get('.boardCell--value').should('have.length', 3)
    })
  })

  it('should merge colliding cells #4', () => {
    allDirections.forEach(dir => {
      let board = '', targetIdx1 = 0, targetIdx2 = 0
      switch (dir) {
        case DIR_LEFT:
          board = b('4_0_2_2', '0_0_0_0', '0_0_0_0', '0_0_0_0');
          targetIdx1 = 0;
          targetIdx2 = 1;
          break;
        case DIR_RIGHT:
          board = b('2_2_0_4', '0_0_0_0', '0_0_0_0', '0_0_0_0');
          targetIdx1 = 3;
          targetIdx2 = 2;
          break;
        case DIR_UP:
          board = b('0_4_0_0', '0_0_0_0', '0_2_0_0', '0_2_0_0');
          targetIdx1 = 1;
          targetIdx2 = 5;
          break;
        case DIR_DOWN:
          board = b('0_2_0_0', '0_2_0_0', '0_0_0_0', '0_4_0_0');
          targetIdx1 = 13;
          targetIdx2 = 9;
          break;
      }
      visitBoardConfig(board)
      clickButton(dir)
      cy.get('.boardCell').eq(targetIdx1).should('contain', '4')
      cy.get('.boardCell').eq(targetIdx2).should('contain', '4')
      cy.get('.boardCell--value').should('have.length', 3)
    })
  })

  it('should preserve the order of cells', () => {
    const initialBoard = '0_2_4_8_0_0_0_0_0_0_0_0_0_0_0_0'
    allDirections.forEach(dir => {
      let board = '', targetIdx1 = 0, targetIdx2 = 0, targetIdx3 = 0
      switch (dir) {
        case DIR_LEFT:
          board = b('0_2_4_8', '0_0_0_0', '0_0_0_0', '0_0_0_0');
          targetIdx1 = 0;
          targetIdx2 = 1;
          targetIdx3 = 2;
          break;
        case DIR_RIGHT:
          board = b('8_4_2_0', '0_0_0_0', '0_0_0_0', '0_0_0_0');
          targetIdx1 = 3;
          targetIdx2 = 2;
          targetIdx3 = 1;
          break;
        case DIR_UP:
          board = b('0_0_0_0', '0_2_0_0', '0_4_0_0', '0_8_0_0');
          targetIdx1 = 1;
          targetIdx2 = 5;
          targetIdx3 = 9;
          break;
        case DIR_DOWN:
          board = b('0_8_0_0', '0_4_0_0', '0_2_0_0', '0_0_0_0');
          targetIdx1 = 13;
          targetIdx2 = 9;
          targetIdx3 = 5;
          break;
      }
      visitBoardConfig(board)
      clickButton(dir)
      cy.get('.boardCell').eq(targetIdx1).should('contain', '2')
      cy.get('.boardCell').eq(targetIdx2).should('contain', '4')
      cy.get('.boardCell').eq(targetIdx3).should('contain', '8')
      cy.get('.boardCell--value').should('have.length', 4)
    })
  })
})

describe('new game button', () => {

  it('should create a new board when clicked', () => {
    visitBoardConfig(b('2_2_2_2', '2_2_2_2', '2_2_2_2', '2_2_2_2'))
    cy.contains('New game').click()
    expectNewGameState()
  })

  it('should display controls and hide message when clicked after winning', () => {
    visitBoardConfig(wonGameConfiguration)
    cy.contains('New game').click()
    expectNewGameState()
  })

  it('should display controls and hide message when clicked after losing', () => {
    visitBoardConfig(lostGameConfiguration)
    cy.contains('New game').click()
    expectNewGameState()
  })
})

describe('winning a game', () => {

  const expectWonState = () => {
    // Expect: won message is shown
    cy.contains('Congratulations, you won!')
      .should('have.class', 'wonMessage')
    // Expect: controls are not shown
    cy.get('div').filter('.controls').should('have.length', 0)
    // Expect: new cell is not generated
    cy.get('.boardCell--value').should('have.length', 2)
  }

  it('should be in won state after doing a winning move', () => {
    visitBoardConfig(b('1024_0_1024_2', '0_0_0_0', '0_0_0_0', '0_0_0_0'))
    cy.get('.buttonLeft').click()
    expectWonState()
  })

  it('should be in won state when loading a board with 2048', () => {
    visitBoardConfig(wonGameConfiguration)
    expectWonState()
  })
})

describe('losing a game', () => {

  const expectLostState = () => {
    // Expect: lost message is shown
    cy.contains('Game over, there are no possible moves remaining.')
      .should('have.class', 'lostMessage')
    // Expect: controls are not shown
    cy.get('div').filter('.controls').should('have.length', 0)
  }

  it('should be in lost state after doing a losing move', () => {
    visitBoardConfig(b('2_4_8_16', '4_8_16_32', '8_16_32_64', '0_32_64_128'))
    cy.get('.buttonLeft').click()
    expectLostState()
  })

  it('should be in lost state when loading a board with no moves left', () => {
    visitBoardConfig(lostGameConfiguration)
    expectLostState()
  })
})