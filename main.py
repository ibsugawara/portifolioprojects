# %%
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

df = pd.read_csv("Students Social Media Addiction.csv")
pd.set_option('display.float_format', lambda x: '%.2f' % x)
df = df.drop(columns=["Student_ID"])

# %%
print(df.describe())
# %%
print(df.isnull().sum())
# %%
print(df.nunique())
# %%
print(df.sort_values(by="Addicted_Score", ascending=False).head(10))
# %%
print(df.corr(numeric_only=True))

# %%
sns.heatmap(df.corr(numeric_only=True), annot=True, cmap="coolwarm")
plt.xticks(rotation=45, ha="right")
plt.yticks(rotation=0)
plt.tight_layout()
plt.show()

# %%
age_average = df.groupby("Age")['Addicted_Score'].mean()
age_average.plot(kind="bar", figsize=(16,2))
plt.xlabel("Age")
plt.ylabel("Average Addiction Score")
plt.title("Average Addiction Score by Age")
plt.show()

# %%
plt.figure(figsize=(16,4))
sns.boxplot(x="Age", y="Addicted_Score", data=df)
plt.title("Addicted Score Distribution by Age")
plt.show()

# %%
sleep_average = df.groupby("Sleep_Hours_Per_Night")['Avg_Daily_Usage_Hours'].mean()
sleep_average.plot(kind="bar", figsize=(16,2))
plt.xlabel("Sleep Hours Per Night")
plt.ylabel("Average Daily Usage Hours")
plt.title("Average Sleep Per Night vs. Daily Cellphone Usage")
plt.show()
# %%
sns.scatterplot(
    data=df,
    x='Avg_Daily_Usage_Hours',
    y='Sleep_Hours_Per_Night'
)
sns.regplot(
    data=df,
    x='Avg_Daily_Usage_Hours',
    y='Sleep_Hours_Per_Night',
    scatter=False, 
    color='red'
)
plt.xlabel("Average Daily Usage Hours")
plt.ylabel("Sleep Hours Per Night")
plt.title("Sleep Duration vs. Daily Cellphone Usage")
plt.show()
# %%
