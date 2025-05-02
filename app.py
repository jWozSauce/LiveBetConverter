import streamlit as st

# Conversion functions
def us_to_dec(odds_us: float) -> float:
    """Convert US odds to decimal odds."""
    if odds_us > 0:
        return odds_us / 100 + 1
    else:
        return 100 / abs(odds_us) + 1


def prob_to_us(p: float) -> int:
    """Convert a probability (0-1) to US odds."""
    if p <= 0 or p >= 1:
        return None
    # For probabilities >= 0.5, odds are negative
    if p >= 0.5:
        return -round((p / (1 - p)) * 100)
    # For probabilities < 0.5, odds are positive
    return round(((1 - p) / p) * 100)


def implied_probs(decimal_odds: list[float]) -> list[float]:
    """Compute no-vig implied probabilities from decimal odds."""
    inv = [1 / od for od in decimal_odds]
    total = sum(inv)
    return [i / total for i in inv]

# App title
st.title("Value Odds Calculator")

# Customizable labels
label_over = st.text_input(
    "Label for Over/Away Odds and Results:",
    value="Over/Away Odds (US):"
)
label_under = st.text_input(
    "Label for Under/Home Odds and Results:",
    value="Under/Home Odds (US):"
)

# Value needed input
value_percent = st.number_input(
    "Value Needed (Decimal):",
    value=0.05,
    step=0.01,
    format="%.2f"
)

# Odds inputs
over_odds = st.number_input(
    label_over,
    value=-110,
    step=1,
    format="%d"
)
under_odds = st.number_input(
    label_under,
    value=-110,
    step=1,
    format="%d"
)

# Compute no-vig probabilities and derived metrics
decimal_odds = [us_to_dec(over_odds), us_to_dec(under_odds)]
probs = None
fair_odds = [None, None]
value_odds = [None, None]

# Try to compute implied probabilities, handle exceptions
try:
    probs = implied_probs(decimal_odds)
    # Fair odds from no-vig probabilities
    fair_odds = [prob_to_us(p) for p in probs]
    # Value odds by subtracting value_percent
    value_odds = [prob_to_us(p - value_percent) for p in probs]
except Exception:
    probs = [None, None]
    fair_odds = [None, None]
    value_odds = [None, None]

# Display results
st.header("Results")

# Value Odds section
st.subheader("Value Odds")
st.write(f"{label_over} {value_odds[0] if value_odds[0] is not None else 'N/A'}")
st.write(f"{label_under} {value_odds[1] if value_odds[1] is not None else 'N/A'}")

# Fair Odds section
st.subheader("Fair Odds")
st.write(f"{label_over} Fair Odds: {fair_odds[0] if fair_odds[0] is not None else 'N/A'}")
st.write(f"{label_under} Fair Odds: {fair_odds[1] if fair_odds[1] is not None else 'N/A'}")

# Fair Probabilities section
st.subheader("Fair Probabilities")
st.write(f"{label_over} Fair Probability: {round(probs[0], 4) if probs[0] is not None else 'N/A'}")
st.write(f"{label_under} Fair Probability: {round(probs[1], 4) if probs[1] is not None else 'N/A'}")
