# Visualization and Sonification of Heart Data with Processing and Pure Data
# Juan Miguel Rojas & José Manuel García

This project combines data visualization and sonification from a heart rate dataset, using Processing to display dynamic visuals and Pure Data to generate sounds that consistently represent the data.

## Project Description

The goal of this project is to display data from a CSV file while simultaneously producing sounds that reflect the patterns in the visualized data. As each piece of data is read from the dataset, a visualization is generated in Processing, accompanied by a sound in Pure Data that corresponds to the rate and intensity of the data being visualized.

## Dataset Used

The dataset used comes from Kaggle and is titled "dataset_heart". This clean dataset contains various variables, such as:
- Age
- Sex
- Blood pressure
- Maximum heart rate
- Type of chest pain, among others.

The main goal of the dataset is to predict the presence or absence of heart disease based on these variables.

## Selected Variables

For this project, the following variables were selected:
- **Maximum Heart Rate**: Used to define the pumping speed in the heart visualization.
- **Heart Disease**: Indicates the presence or absence of heart disease. A specific value (e.g., 2) represents the presence of heart disease.

## Visualization in Processing

In Processing, an animation of a heart is displayed, which changes size to simulate pumping, based on the value of the maximum heart rate column in the dataset. When heart disease is detected, the heart visually appears "broken" or split to indicate the condition.

## Sonification in Pure Data

For the sonification part, a connection is established between Processing and Pure Data via the OSC (Open Sound Control) protocol. Each time the heart pumps in Processing, a message is sent to Pure Data, which generates a kick drum sound.

## Technologies Used

- **Processing**: For graphical visualization of the data.
- **Pure Data**: For sound generation synchronized with the visualization in Processing.
- **OSC Protocol**: For sending real-time data from Processing to Pure Data.
