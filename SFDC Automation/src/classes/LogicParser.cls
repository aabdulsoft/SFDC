/******************************************************************************************
 *  Purpose : Utility class called from CustomSearchController for the Filters and Search section of the application.
 *  Author  : Manisha Gupta
 *  Date    : 2014-02-19
 *  Version : 1.0
 *
 *  Modification History
 *  Date        Who   Description
 *
 ********************************************************************************************/
public with sharing class LogicParser {

	public static String mapLogic(String logic,String[] conditions)
	{
		LogicParser lp = new LogicParser();
		lp.parse(logic);
		return lp.mapConditions(conditions);
	}

	//public static LIst<String> LOG = new List<String>();
	public LogicParser()
	{

	}

	private static Set<String> BINARY_OPERATORS = new Set<String>{'AND','OR'};
	private static Set<String> UNARY_OPERATORS = new Set<String>{'NOT'};

	//private static Integer INDENTATION = 0;

	private Expression expression = null;



	private void verifyConditionsRecursive(Expression curExpression)
	{

		String logic = curExpression.logic;
		//INDENTATION++;
		Integer i = 0;
		//first base expressions
		for(Expression exp : curExpression.children)
		{
			i++;
			if(!exp.isBaseExpression()) continue;
			validateBaseExpression(exp.logic);

			logic = logic.replace('('+exp.logic+')',String.valueOf(i));

		}

		//second complex expressions
		i=0;
		//for(i = 0; i < curExpression.children.size(); i++)
		for(Expression exp : curExpression.children)
		{
			//Expression exp = curExpression.children[i];
			i++;
			if(exp.isBaseExpression()) continue;
			verifyConditionsRecursive(exp);
			logic = logic.replace('('+exp.logic+')',String.valueOf(i));


		}
		//LOG.add(INDENTATION+' Validated: '+logic);
		//INDENTATION--;
		validateBaseExpression(logic);
	}




	private Integer currentPosition = null;

	public enum EXP_TYPE {EXPRESSION,OPERATOR}


	public class Expression
	{
		public Expression father = null;
		public String logic = '';
		public List<Expression> children = new List<Expression>();
		public EXP_TYPE type;
		public Boolean isBaseExpression()
		{
			return this.logic.contains('(') == false;
		}


		public Expression(Expression father, String logic, EXP_TYPE type)
		{
			this.father = father;
			this.logic = logic;
			this.type = type;
		}


	}

	public static String[] validateBaseExpression(String logic)
	{
		String[] tokens = logic.trim().split('\\s+');

		if(tokens.size()==2)
		{
			if(UNARY_OPERATORS.contains(tokens[0]) == false)  throw new CustomException(tokens[0]+': wrong unary operator'+logic);
			//LOG.add(INDENTATION+' BINARY CONDITION: '+logic);
		}
		else if(tokens.size()>1)
		{
			Integer i = 0;
			while(i<tokens.size())
			{
				String s0 = tokens[i];

				if(UNARY_OPERATORS.contains(s0))
				{
					if((i == tokens.size()-1) || UNARY_OPERATORS.contains(tokens[i+1]) || BINARY_OPERATORS.contains(tokens[i+1])
						|| (i>0 && (UNARY_OPERATORS.contains(tokens[i-1])==false && BINARY_OPERATORS.contains(tokens[i-1])==false)))
					{
						throw new CustomException(s0+' : expected operand '+logic);
					}
					i+=2;
					continue;
				}
				else if(BINARY_OPERATORS.contains(s0))
				{
					if(i-1 < 0)
					{
						throw new CustomException(s0+' : missing operand '+logic);
					}

					if((i == tokens.size()-1) || UNARY_OPERATORS.contains(tokens[i+1]) || BINARY_OPERATORS.contains(tokens[i+1])
						|| UNARY_OPERATORS.contains(tokens[i-1]) || BINARY_OPERATORS.contains(tokens[i-1]))
					{
						throw new CustomException(s0+' : expected operand '+logic);
					}
					i+=3;
					continue;
				}
				else
				{
					i+=1;
					continue;
				}
			}
		}
		else if(tokens.size()==1)
		{
			//LOG.add(INDENTATION+' UNARY CONDITION: '+logic);
		}
		return tokens;

	}

	public class CustomException extends Exception{}


	public void parse(String logic)
	{
		logic = logic.replace('(',' ( ');
		logic = logic.replace(')',' ) ');
		logic = logic.replace('\\s+',' ');
		this.expression =  new Expression(null,logic,EXP_TYPE.EXPRESSION);
		parseLogic(logic,expression);

		//verify logic conditions
		verifyConditionsRecursive(this.expression);
	}
	public String mapConditions(List<String> conditions)
	{
		String query =  mapConditionsRecursive(conditions,this.expression);
		String output = '';
		for(String s : query.trim().split('\\s+') )
		{
			if(s=='(' || s==')' ||  BINARY_OPERATORS.contains(s) || UNARY_OPERATORS.contains(s))
			{
				output+=' '+s+' ';
			}
			else if(numberPattern.matcher(s).matches())
			{
				Integer condNumber = Integer.valueOf(s)-1;
				if( condNumber < 0 || condNumber >= conditions.size()) throw new CustomException((condNumber+1)+' is not a valid condition number ');
				String condition = conditions[condNumber];
				if(condition == '') throw new CustomException('Condition '+(condNumber+1)+' is a void condition' );
				output+=' '+conditions[condNumber]+' ';
			}
			else throw new CustomException(s+' is not a valid condition');


		}
		return output;
	}

	static Pattern numberPattern = Pattern.compile('[0-9]+');

	private String mapConditionsRecursive(List<String> conditions, Expression current)
	{
		String logic = current.logic;
		for(Expression exp : current.children)
		{

			if(exp.isBaseExpression())
			{
				//logic = logic.replace('('+exp.logic+')','( B )');
			}
			else
			{
				logic = logic.replace('('+exp.logic+')','('+mapConditionsRecursive(conditions,exp)+')');
			}
		}

		return logic;
	}


	private Boolean parseLogic(String logic, Expression currentExpression)
	{
		if(currentPosition == null) currentPosition = 0;

		Boolean foundOpen = false;
		Boolean foundClose = false;

		Integer startPos = currentPosition;
		while(currentPosition < logic.length())
		{
			String ch = logic.substring(currentPosition,currentPosition+1);
			currentPosition++;
			if(ch == ')' && startPos > 0)
			{
				return true;
			}
			else if(ch == ')') throw new CustomException('Unexpected ")" @ '+currentPosition);

			if(ch == '(')
			{
				foundOpen = true;
				Integer startExpression = currentPosition;
				Expression childExpression = new Expression(currentExpression,'',EXP_TYPE.EXPRESSION);

				foundClose = parseLogic(logic,childExpression);
				if(foundClose)
				{
					childExpression.logic = logic.subString(startExpression,currentPosition-1);
					currentExpression.children.add(childExpression);
				}
			}



			if(foundOpen && !foundClose) throw new CustomException('Missing closing ")" @ '+currentPosition);
		}
		return false;
	}
}