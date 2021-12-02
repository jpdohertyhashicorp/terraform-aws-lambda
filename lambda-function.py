import os
import requests

token = os.getenv('api_token')

def get_financals_from_response(response):
	try:
		response_as_json = response.json()
		financials = response_as_json["financials"]
		return financials[0]
	except (TypeError, IndexError, KeyError):
		return {}

def get_income_ttm(symbol):
	response = requests.get('https://finnhub.io/api/v1/stock/financials?symbol=' + symbol + '&statement=ic&freq=ttm&token=' + token)
	return get_financals_from_response(response)

def get_quarterly_balance_sheet(symbol):
	response = requests.get('https://finnhub.io/api/v1/stock/financials?symbol=' + symbol + '&statement=bs&freq=quarterly&token=' + token)
	return get_financals_from_response(response)

def get_marketcap(symbol):
	try:
		response = requests.get('https://finnhub.io/api/v1/stock/profile?symbol=' + symbol + '&token=' + token)
		response_json = response.json()
		shares = response_json["shareOutstanding"]
		response = requests.get('https://finnhub.io/api/v1/quote?symbol=' + symbol + '&token=' + token)
		response_json = response.json()
		price = response_json["c"]
		return shares * price
	except KeyError:
		return -1

def get_value_or_zero(dictionary, key):
	try:
		return dictionary[key]
	except KeyError:
		return 0
	
def get_value_or_neg_one(dictionary, key):
	try:
		value = dictionary[key]
		if value != 0:
			return value
		return -1
	except KeyError:
		return -1

def get_roic(ebit, debt, equity, cash):
	if (debt == -1) or (equity == -1):
		return 0
	try:
		return ebit / (debt + equity - cash) * 100
		# This is a bug.  You are missing out on a lot of opportunities where numbers are good but calculations come out to negative numbers.
		# Also you are potentially buying some bad stocks if you don't look at individual numbers like just ebit alone
	except TypeError:
		return 0

def lambda_handler(event, context):
	symbol = event['symbol']
	income_ttm = get_income_ttm(symbol)
	balance_sheet = get_quarterly_balance_sheet(symbol)
	ebit = get_value_or_zero(income_ttm, "ebit")
	debt = get_value_or_neg_one(balance_sheet, "totalDebt")
	equity = get_value_or_neg_one(balance_sheet, "totalEquity")
	cash = get_value_or_zero(balance_sheet, "cashShortTermInvestments")
	roic = get_roic(ebit, debt, equity, cash)
	marketcap = get_marketcap(symbol)
	faustmann = marketcap / equity
	return { 
        'roic': roic,
		'faustmann': faustmann
    }