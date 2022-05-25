// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;

import {SafeMath} from '../../dependencies/aave-core/dependencies/openzeppelin/contracts/SafeMath.sol';
import {WadRayMath} from '../../dependencies/aave-core/protocol/libraries/math/WadRayMath.sol';
import {PercentageMath} from '../../dependencies/aave-core/protocol/libraries/math/PercentageMath.sol';
import {IAnteiDiscountRateStrategy} from '../tokens/interfaces/IAnteiDiscountRateStrategy.sol';

/**
 * @title AnteiDiscountRateStrategy contract
 * @notice Implements the calculation of the discount rate depending on the current strategy
 * @author Aave
 **/
contract AnteiDiscountRateStrategy is IAnteiDiscountRateStrategy {
  using PercentageMath for uint256;
  using WadRayMath for uint256;
  using SafeMath for uint256;

  uint256 public constant ASD_DISCOUNTED_PER_TOKEN_STAKED = 100e18;
  uint256 public constant DISCOUNT_RATE = 2000;
  uint256 public constant MIN_DISCOUNT_TOKEN_BALANCE = 1e18;

  /**
   * @dev Calculates the interest rates depending on the reserve's state and configurations
   * @param debtBalance The address of the reserve
   * @param discountTokenBalance The liquidity available in the reserve
   * @return The discount rate, as a percentage - the maximum can be 10000 = 100.00%
   **/
  function calculateDiscountRate(uint256 debtBalance, uint256 discountTokenBalance)
    external
    view
    override
    returns (uint256)
  {
    if (discountTokenBalance < MIN_DISCOUNT_TOKEN_BALANCE || debtBalance == 0) {
      return 0;
    } else {
      uint256 discountedBalance = discountTokenBalance.wadMul(ASD_DISCOUNTED_PER_TOKEN_STAKED);
      if (discountedBalance >= debtBalance) {
        return DISCOUNT_RATE;
      } else {
        uint256 discountRateWad = discountedBalance.percentMul(DISCOUNT_RATE).wadDiv(debtBalance);
        return discountRateWad.div(1e14);
      }
    }
  }
}
