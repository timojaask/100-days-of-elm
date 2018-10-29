const b = (row0, row1, row2, row3) => {
  return `${row0}_${row1}_${row2}_${row3}`
}

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

const expectToBeNewBoard = () => {
  expectToHaveOneValueCell()
  expectToHave15EmptyCells()
}

const expectBoardToBe = boardConfig => {
  const expectedValues = boardConfig.split('_')
  cy.get('.boardCell span').each(($span, index) => {
    const text = $span.text()
    expect(text).to.equal(expectedValues[index])
  })
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
})

describe('board with query', () => {
  it('should be new board when a value in query is invalid', () => {
    visitBoardConfig(b('3_8_8_8', '8_8_8_8', '8_8_8_8', '8_8_8_8'))
    expectToBeNewBoard()
  })

  it('should be new board when the number of values is invalid', () => {
    visitBoardConfig('8_8_8_8_8_8_8_8_8_8')
    expectToBeNewBoard()
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
      const initialBoard = b('0_0_0_0', '0_2_0_0', '0_0_0_0', '0_0_0_0')
      visitBoardConfig(initialBoard)
      clickButton(dir)
      cy.get('.boardCell--value').should('have.length', 2)
    })
  })

  it('should not add new value when move has no effect', () => {
    allDirections.forEach(dir => {
      let initialBoard = ''
      switch (dir) {
        case DIR_LEFT: initialBoard = b('2_0_0_0', '0_0_0_0', '0_0_0_0', '0_0_0_0'); break;
        case DIR_RIGHT: initialBoard = b('0_0_0_2', '0_0_0_0', '0_0_0_0', '0_0_0_0'); break;
        case DIR_UP: initialBoard = b('0_2_0_0', '0_0_0_0', '0_0_0_0', '0_0_0_0'); break;
        case DIR_DOWN: initialBoard = b('0_0_0_0', '0_0_0_0', '0_0_0_0', '0_0_2_0'); break;
      }
      visitBoardConfig(initialBoard)
      clickButton(dir)
      cy.get('.boardCell--value').should('have.length', 1)
    })
  })

  it('should move a cell and stop at wall', () => {
    // TODO: Fix this to work with all directions
    // allDirections.forEach(dir => {
    //   const initialBoard = '0_0_0_0_0_0_256_0_0_0_0_0_0_0_0_0'
    //   let initialBoard = ''
    //   switch (dir) {
    //     case DIR_LEFT: initialBoard = '0_0_0_0_0_0_8_0_0_0_0_0_0_0_0_0'; break;
    //     case DIR_RIGHT: initialBoard = '0_0_0_0_0_8_0_0_0_0_0_0_0_0_0_0'; break;
    //     case DIR_UP: initialBoard = '0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0'; break;
    //     case DIR_DOWN: initialBoard = '0_0_0_0_0_0_0_0_0_0_0_0_0_0_2_0'; break;
    //   }
    //   visitBoardConfig(initialBoard)
    //   cy.get('.buttonLeft').click()
    //   cy.get('.boardCell').eq(4).should('contain', '8')
    // })
  })

  describe('left', () => {

    it('should move a cell left and stop at a different cell', () => {
      const initialBoard = '0_0_0_0_128_0_256_0_0_0_0_0_0_0_0_0'
      visitBoardConfig(initialBoard)
      cy.get('.buttonLeft').click()
      cy.get('.boardCell').eq(4).should('contain', '128')
      cy.get('.boardCell').eq(5).should('contain', '256')
    })

    it('should merge colliding cells #1', () => {
      const initialBoard = '2_0_2_0_0_0_0_0_0_0_0_0_0_0_0_0'
      visitBoardConfig(initialBoard)
      cy.get('.buttonLeft').click()
      cy.get('.boardCell').eq(0).should('contain', '4')
      cy.get('.boardCell--value').should('have.length', 2)
    })

    it('should merge colliding cells #2', () => {
      const initialBoard = '0_2_2_0_0_0_0_0_0_0_0_0_0_0_0_0'
      visitBoardConfig(initialBoard)
      cy.get('.buttonLeft').click()
      cy.get('.boardCell').eq(0).should('contain', '4')
      cy.get('.boardCell--value').should('have.length', 2)
    })

    it('should merge colliding cells #3', () => {
      const initialBoard = '2_2_2_2_0_0_0_0_0_0_0_0_0_0_0_0'
      visitBoardConfig(initialBoard)
      cy.get('.buttonLeft').click()
      cy.get('.boardCell').eq(0).should('contain', '4')
      cy.get('.boardCell').eq(1).should('contain', '4')
      cy.get('.boardCell--value').should('have.length', 3)
    })

    it('should merge colliding cells #4', () => {
      const initialBoard = '4_0_2_2_0_0_0_0_0_0_0_0_0_0_0_0'
      visitBoardConfig(initialBoard)
      cy.get('.buttonLeft').click()
      cy.get('.boardCell').eq(0).should('contain', '4')
      cy.get('.boardCell').eq(1).should('contain', '4')
      cy.get('.boardCell--value').should('have.length', 3)
    })

    it('should preserve the order of cells', () => {
      const initialBoard = '0_2_4_8_0_0_0_0_0_0_0_0_0_0_0_0'
      visitBoardConfig(initialBoard)
      cy.get('.buttonLeft').click()
      cy.get('.boardCell').eq(0).should('contain', '2')
      cy.get('.boardCell').eq(1).should('contain', '4')
      cy.get('.boardCell').eq(2).should('contain', '8')
    })
  })
})

// tile merging

// new tile generation