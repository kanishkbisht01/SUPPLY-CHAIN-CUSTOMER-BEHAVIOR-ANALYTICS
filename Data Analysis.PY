import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# 1. LOAD DATA
df = pd.read_csv(
    r'C:\Users\kanishk\Downloads\DataCoSupplyChainDataset.csv',
    encoding='utf-8-sig'
)

# 2. DROP UNNECESSARY COLUMNS
df.drop(['Product_Description', 'Order_Zipcode'], axis=1, inplace=True)

# 3. BASIC OVERVIEW
print("Shape:", df.shape)
print("\nColumns:\n", df.columns.tolist())
print("\nInfo:")
df.info()

# 4. NULL VALUE HANDLING
# Specific columns

df['Customer_Lname'] = df['Customer_Lname'].fillna('Unknown')
df['Customer_Zipcode'] = df['Customer_Zipcode'].fillna(0)

print("\nNull counts before fill:\n", df.isnull().sum())  # Null check before fill
print("\nNull % before fill:\n", (df.isnull().sum() / len(df)) * 100) 

# Numeric columns
df.fillna(df.mean(numeric_only=True), inplace=True)

# categorical columns 'Unknown'
df.fillna('Unknown', inplace=True)


print("\nNull counts after fill:\n", df.isnull().sum())   # Null check after fill

# 5. DATE PROCESSING
df = df.dropna(subset=['order_date'])

df['order_date'] = pd.to_datetime(
    df['order_date'],
    format='%m/%d/%Y %H:%M',
    errors='coerce'
)

df = df.dropna(subset=['order_date'])

df['Year'] = df['order_date'].dt.year
df['Month'] = df['order_date'].dt.month
df['Day'] = df['order_date'].dt.day

print("\nDate range:", df['order_date'].min(), "to", df['order_date'].max())

# 6. KPIs

total_sales       = df['Sales'].sum()
total_profit      = df['Order_Profit_Per_Order'].sum()
avg_order_value   = df['Sales'].mean()
late_delivery_pct = df['Late_delivery_risk'].mean() * 100

print(f"Total Sales       : {round(total_sales, 2)}")
print(f"Total Profit      : {round(total_profit, 2)}")
print(f"Avg Order Value   : {round(avg_order_value, 2)}")
print(f"Late Delivery %   : {round(late_delivery_pct, 2)}%")

# 7. FEATURE

df['Profit_Margin'] = (
    df['Order_Profit_Per_Order'] / df['Sales'].replace(0, float('nan'))
) * 100

# Delivery_Status

df['Late'] = df['Delivery_Status'].apply(
    lambda x: 1 if isinstance(x, str) and 'Late' in x else 0
)

# Verify
print("\n--- Profit Margin Stats ---")
print(df['Profit_Margin'].describe())
print("\nSample rows:")
print(df[['Sales', 'Order_Profit_Per_Order', 'Profit_Margin', 'Late']].head(10))

# 8. VISUALIZATION

# 8.1 Monthly Sales Trend
plt.figure(figsize=(12, 6))
df.groupby(['Year', 'Month'])['Sales'].sum().plot(
    kind='line', marker='o', color='green'
)
plt.title('Monthly Sales Trend (2015-2018)')
plt.ylabel('Total Sales')
plt.xlabel('Year, Month')
plt.grid(True)
plt.tight_layout()
plt.show()

# 8.2 Top 10 Most Profitable Categories
top_categories = (
    df.groupby('Category_Name')['Order_Profit_Per_Order']
    .sum()
    .sort_values(ascending=False)
    .head(10)
)
plt.figure(figsize=(10, 6))
sns.barplot(x=top_categories.values, y=top_categories.index, palette='viridis')
plt.title('Top 10 Most Profitable Categories')
plt.xlabel('Total Profit')
plt.tight_layout()
plt.show()

# 8.3 Late Delivery Heatmap
pivot_table = df.pivot_table(
    index='Market',
    columns='Shipping_Mode',
    values='Late',
    aggfunc='mean'
)
plt.figure(figsize=(10, 5))
sns.heatmap(pivot_table, annot=True, fmt='.2f', cmap='Reds')
plt.title('Late Delivery Probability by Market and Shipping Mode')
plt.tight_layout()
plt.show()

df.to_csv(
    r'C:\Users\kanishk\Downloads\DataCo_Cleaned.csv',
    index=False,
    encoding='utf-8-sig'
)