# import sys
# import csv
# from Bio import SeqIO
# from Bio.SeqUtils.ProtParam import ProteinAnalysis

# def calculate_epsilon_and_MW(sequence):
#     X = ProteinAnalysis(sequence)
#     epsilon = X.molar_extinction_coefficient()
#     MW = X.molecular_weight()
#     return epsilon, MW

# def main(fasta_file, output_file):
#     # Read FASTA file
#     records = SeqIO.parse(fasta_file, "fasta")

#     with open(output_file, 'w', newline='') as csvfile:
#         fieldnames = ["ID", "shortID", "Priority", "Received", "Name", "Project", "Antibodies", "Date", "Plasmid",
#                       "Epsilon", "Epsilon/1000", "MW", "MW/1000", "e/MW", "Order", 
#                       "ogDNAloc", "DNAmaxiloc", "concDNAprep", "Instructions", "FurinConc", "TransfectionDate",
#                       "cellType", "Media", "transfectionReagent", "Volume", "Purification", 
#                       "lectinColumn", "Column"]
#         writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
#         writer.writeheader()

#         for record in records:
#             sequence = str(record.seq)
#             modified_sequence = sequence.replace("*", "")
#             epsilon_prot, MW_prot = calculate_epsilon_and_MW(modified_sequence)

#             # shortID
#             shortID = record.id
#             # PGT151/BB and 35O22
#             shortID = record.id.split("_translation_extraction")[0]
            
#             writer.writerow({
#                 "ID": record.id if record.id else "error",
#                 "shortID": shortID if shortID else record.id if record.id else "error",
#                 "Priority": None,
#                 "Received": "Yes",
#                 "Name": "Colby",
#                 "Project": "project",
#                 "Antibodies": None,
#                 "Date": "date",
#                 "Plasmid": "Plasmid",
#                 "Epsilon": epsilon_prot[1] if epsilon_prot else "error",
#                 "Epsilon/1000": epsilon_prot[1] / 1000 if epsilon_prot else "error",
#                 "MW": MW_prot if MW_prot else "error",
#                 "MW/1000": MW_prot / 1000 if MW_prot else "error",
#                 "e/MW": epsilon_prot[1] / MW_prot if MW_prot and epsilon_prot else "error",
#                 "Order": "Order",
#                 "ogDNAloc": None,
#                 "DNAmaxiloc": "To be transfected",
#                 "concDNAprep": None,
#                 "Instructions": None,
#                 "FurinConc": None,
#                 "TransfectionDate": None,
#                 "cellType": "Media",
#                 "Media": "Media",
#                 "transfectionReagent": "transfectionReagent",
#                 "Volume": "Volume",
#                 "Purification": "Purification",
#                 "lectinColumn": None,
#                 "Column": "Column",
#             })

# if __name__ == "__main__":
#     if len(sys.argv) != 3:
#         print("Usage: python script.py fasta_file.fasta output.csv")
#         sys.exit(1)
    
#     fasta_file = sys.argv[1]
#     output_file = sys.argv[2]
#     main(fasta_file, output_file)

# draft (work on IO and plateID and concatenating dfs)
# PGT151
import pandas as pd
path1 = '/Users/colbyagostino/Library/CloudStorage/Box-Box/Kulp lab/small scale/Queue/BB_PGT151.csv'
path2 = '/Users/colbyagostino/Library/CloudStorage/Box-Box/Kulp lab/small scale/Twist/platemap_pSHPs0103B2222016N_BB_PGT151_A_05Jan24.csv'
path3 = '/Users/colbyagostino/Library/CloudStorage/Box-Box/Kulp lab/small scale/Twist/platemap_pSHPs0110B200701HX_BB_PGT151_A_12Jan24.csv'
path4 = '/Users/colbyagostino/Library/CloudStorage/Box-Box/Kulp lab/small scale/Twist/platemap_pSHPs0110B209701HX_BB_PGT151_B_12Jan24.csv'
path5 = '/Users/colbyagostino/Library/CloudStorage/Box-Box/Kulp lab/small scale/Twist/platemap_pSHPs0122B5375016N_BB_PGT151_B_24Jan24.csv'
path6 = '/Users/colbyagostino/Library/CloudStorage/Box-Box/Kulp lab/small scale/Twist/platemap_pSHPs0122B5377016N_BB_PGT151_A_24Jan24.csv'
path7 = '/Users/colbyagostino/Library/CloudStorage/Box-Box/Kulp lab/small scale/Twist/platemap_pSHPs1231B473701IQ_BB_PGT151_B_03Jan24.csv'

df1 = pd.read_csv(path1)
df1.info()
df2 = pd.read_csv(path2)
df2.info()
df3 = pd.read_csv(path3)
df3.info()
df4 = pd.read_csv(path4)
df4.info()
df5 = pd.read_csv(path5)
df5.info()
df6 = pd.read_csv(path6)
df6.info()
df7 = pd.read_csv(path7)
df7.info()

concatenated_df = pd.concat([df2, df3, df4, df5, df6, df7])
concatenated_df_subset = concatenated_df[['Name', 'Well Location', 'Plate ID', 'Order #']]
merged_df = pd.merge(df1, concatenated_df_subset, left_on='shortID', right_on='Name', how='left')
merged_df['Name + Well Location'] = merged_df['shortID'] + ' (' + merged_df['Well Location'] + ')'
merged_df['Order'] = merged_df['Order #']
merged_df.drop(columns=['Order #'], inplace=True)

# Print the resulting merged dataframe
# print(merged_df)
merged_df.to_csv('output_file.csv', index=False)

# # 35O22
# import pandas as pd
# path1 = '/Users/colbyagostino/Library/CloudStorage/Box-Box/Kulp lab/small scale/Queue/35O22.csv'
# path2 = '/Users/colbyagostino/Library/CloudStorage/Box-Box/Kulp lab/small scale/Twist/platemap_pSHPs1227B565601IQ_35O22_02Jan24.csv'


# df1 = pd.read_csv(path1)
# df1.info()
# df2 = pd.read_csv(path2)
# df2.info()

# df2_subset = df2[['Name', 'Well Location', 'Plate ID', 'Order #']]
# merged_df = pd.merge(df1, df2_subset, left_on='shortID', right_on='Name', how='left')
# merged_df['Name + Well Location'] = merged_df['shortID'] + ' (' + merged_df['Well Location'] + ')'
# merged_df['Order'] = merged_df['Order #']
# merged_df.drop(columns=['Order #'], inplace=True)


# # Print the resulting merged dataframe
# # print(merged_df)
# merged_df.to_csv('output_file.csv', index=False)