//
//  AppTextManager.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/6/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation

struct AppText {
    
    /*static let Language = [
        "en":TextBase.self,
        //"vi":Vietnamese.self
    ]*/
    
    /*static func getText() -> TextBase.Type {
        return TextBase.self
//        let lang = AppLanguage.appLanguage()
//        switch lang {
//        case "vi":
//            return Vietnamese.self
//        default:
//            return TextBase.self
//        }
    }*/
    
    static var firebaseFolder: String {get {return NSLocalizedString("firebaseFolder", comment: "")}}
//    static var addEdit: String           {get {return NSLocalizedString("Add / edit Flash Cubes", comment: "")}}
//    static var addNew: String            {get {return NSLocalizedString("Add new", comment: "")}}
    static var addSecondaryPrompt: String{get {return NSLocalizedString("Add secondary prompt if desired", comment: "")}}
//    static var addSide: String           {get {return NSLocalizedString("Add another side", comment: "")}}
    static var addTextHere: String       {get {return NSLocalizedString("Add text here", comment: "")}}
    static var atleastTwoSides: String   {get {return NSLocalizedString("Must have at least two sides", comment: "")}}
//    static var audio: String             {get {return NSLocalizedString("Audio", comment: "")}}
    static var audioPlaybackSpeed: String {get {return NSLocalizedString("Audio playback speed:", comment: "")}}
//    static var audioPrompt : String      {get {return NSLocalizedString("Audio prompt", comment: "")}}
//    static var averageProficiency: String {get {return NSLocalizedString("Average proficiency:", comment: "")}}
    static var begin: String            {get {return NSLocalizedString("Begin", comment: "")}}
    static var buy: String               {get{return NSLocalizedString("Buy", comment: "")}}
    static var cancel: String            {get {return NSLocalizedString("Cancel", comment: "")}}
//    static var cantSave: String          {get{return NSLocalizedString("Unable to save at this time", comment: "")}}
//    static var choosePrompts: String     {get {return NSLocalizedString("Choose review prompts", comment: "")}}
    static var categories: String            {get {return NSLocalizedString("Categories", comment: "")}}
    static var continueTxt: String       {get {return NSLocalizedString("Continue", comment: "")}}
//    static var createSides: String       {get {return NSLocalizedString("Create the sides of ", comment: "")}}
    static var date: String            {get {return NSLocalizedString("Date", comment: "")}}
//    static var deckOverviewTitle: String {get {return NSLocalizedString("Deck overview", comment: "")}}
    static var defaultText: String               {get{return NSLocalizedString("Default", comment: "")}}
    static var delete: String            {get {return NSLocalizedString("Delete", comment: "")}}
    static var deleteWarningCube: String     {get {return NSLocalizedString("Flash Cube will be permenantly deleted!", comment: "")}}
    static var deleteWarningDeck: String {get {return NSLocalizedString("All deck data will be permenantly deleted!", comment: "")}}
    static var deleteWarningPrompt: String {get {return NSLocalizedString("Prompt will be deleted", comment: "")}}
    static var download: String               {get{return NSLocalizedString("Download", comment: "")}}
    static var error: String             {get {return NSLocalizedString("Error", comment: "")}}
//    static var flashCubesTitle: String   {get {return NSLocalizedString("Flash Cubes", comment: "")}}
    static var free: String              {get {return NSLocalizedString("Free", comment: "")}}
    static var greatjob: String          {get {return NSLocalizedString("Great job!", comment: "")}}
    static var guessFor: String             {get {return NSLocalizedString("Guess for", comment: "")}}
//    static var image: String             {get {return NSLocalizedString("Image", comment: "")}}
//    static var imagePrompt: String       {get {return NSLocalizedString("Image prompt", comment: "")}}
//    static var instructionAudio: String  {get {return NSLocalizedString("Select audio and you will be able to record and play back any sound.", comment: "")}}
//    static var instrucitonImage: String  {get {return NSLocalizedString("Select image to be able to load an image from your photo library.", comment: "")}}
//    static var instructionText: String   {get {return NSLocalizedString("Select text and you can type in any language your device supports.", comment: "")}}
//    static var keepGoing: String         {get {return NSLocalizedString("Keep going", comment: "")}}
//    static var lastReview: String        {get {return NSLocalizedString("Latest review:", comment: "")}}
    static var learnedNew: String       {get {return NSLocalizedString("Finished set of new Flash Cubes.  Keep going?", comment: "")}}
//    static var learnedNew2: String       {get {return NSLocalizedString(" new words.", comment: "")}}
    static var loading: String {get {return NSLocalizedString("Loading", comment: "")}}
    static var maximumNewAtOneTime: String {get {return NSLocalizedString("Maximum amount of Flash Cubes to learn at once:", comment: "")}}
    static var mustEnterDeckName: String {get {return NSLocalizedString("Must enter a deck name", comment: "")}}
    static var mustEnterPromptName: String {get {return NSLocalizedString("Must enter title for each prompt", comment: "")}}
//    static var never: String             {get {return NSLocalizedString("Never", comment: "")}}
    static var newCubeName: String       {get {return NSLocalizedString("Enter new cube name", comment: "")}}
//    static var newDeck: String           {get {return NSLocalizedString("New deck", comment: "")}}
//    static var newDeckInstruction1: String {get {return NSLocalizedString("A Flash Cube side is just like the side of a flash card.  Add whatever it is you would like to learn.", comment: "")}}
//    static var newDeckInstruction2: String {get {return NSLocalizedString("Make up to six sides, any combination you like.", comment: "")}}
//    static var newDeckInstruction3: String {get {return NSLocalizedString("Slide entry to the left to delete.", comment: "")}}
    static var newDeckName: String       {get {return NSLocalizedString("New deck name", comment: "")}}
    static var newStackFinished: String  {get {return NSLocalizedString("Great job!  You learned a new set of Flash Cubes.  Keep going?", comment: "")}}
    static var noDoublePromptNames: String {get {return NSLocalizedString("No two prompts can have the same title", comment: "")}}
    static var noName: String {get {return NSLocalizedString("No name", comment: "")}}
    static var notice: String            {get {return NSLocalizedString("Notice:", comment: "")}}
    static var noValidCubes: String      {get {return NSLocalizedString("The Flash Cubes in your deck do not have the prompts requested.", comment: "")}}
//    static var numberInDeck: String      {get {return NSLocalizedString("Number of cubes:", comment: "")}}
    static var ok: String                {get {return NSLocalizedString("OK", comment: "")}}
    static var overDueFinished: String   {get {return NSLocalizedString("Great job!  All of the due Flash Cubes have been reviewed.  Keep going?", comment: "")}}
//    static var overWriteDeckInfo: String {get {return NSLocalizedString("Changes made to deck will be permanent.", comment: "")}}
    static var overwriteWarning: String  {get {return NSLocalizedString("Data will be overwritten.", comment: "")}}
    static var proficiency: String         {get {return NSLocalizedString("Proficiency", comment: "")}}
    static var prompts: String         {get {return NSLocalizedString("Prompts", comment: "")}}
    static var promptsCantBeSame: String {get {return NSLocalizedString("Question and answer prompts cannot be the same.", comment: "")}}
//    static var promptsCantBeSameTwo: String {get {return NSLocalizedString("Primary and secondary prompts cannot be the same.", comment: "")}}
//    static var promptsLackData: String   {get {return NSLocalizedString("Enter data for two or more prompts", comment: "")}}
    static var restorePurchases: String  {get {return NSLocalizedString("Restore purchases", comment: "")}}
    static var purchaseFailed: String    {get {return NSLocalizedString("Purchase failed.", comment: "")}}
    static var quit: String              {get {return NSLocalizedString("Quit", comment: "")}}
    static var quitReview: String        {get {return NSLocalizedString("Quit reviewing?", comment: "")}}
//    static var remasteredOld1: String    {get {return NSLocalizedString("You remastered ", comment: "")}}
//    static var remasteredOld2: String    {get {return NSLocalizedString(" previously learned words.", comment: "")}}
    static var retention: String         {get {return NSLocalizedString("Retention", comment: "")}}
    static var reviewAlert: String       {get {return NSLocalizedString("Time to review the following decks!", comment: "")}}
    static var reviewDeck: String        {get {return NSLocalizedString("Review deck", comment: "")}}
    static var save: String              {get {return NSLocalizedString("Save", comment: "")}}
//    static var saveFlashCube: String     {get {return NSLocalizedString("Save Flash Cube", comment: "")}}
    static var saveNewDeck: String       {get {return NSLocalizedString("Save new deck", comment: "")}}
    static var saving: String {get {return NSLocalizedString("Saving", comment: "")}}
//    static var side: String              {get {return NSLocalizedString("Side ", comment: "")}}
    static var sortBy: String            {get {return NSLocalizedString("Sort by:", comment: "")}}
    static var sortDueAsc: String        {get {return NSLocalizedString("Due date ascending", comment: "")}}
    static var sortDueDesc: String       {get {return NSLocalizedString("Due date descending", comment: "")}}
    static var sortNameAsc: String       {get {return NSLocalizedString("Name ascending", comment: "")}}
    static var sortNameDesc: String      {get {return NSLocalizedString("Name descending", comment: "")}}
    static var sortProfAsc: String       {get {return NSLocalizedString("Proficiency ascending", comment: "")}}
    static var sortProfDesc: String      {get {return NSLocalizedString("Proficiency descending", comment: "")}}
    static var sortRetAsc: String        {get {return NSLocalizedString("Retention ascending", comment: "")}}
    static var sortRetDesc: String       {get {return NSLocalizedString("Retention descending", comment: "")}}
//    static var stopForNow: String        {get {return NSLocalizedString("Stop for now", comment: "")}}
//    static var text: String              {get {return NSLocalizedString("Text", comment: "")}}
//    static var textFieldHint: String     {get {return NSLocalizedString("Add a title: eg. French audio", comment: "")}}
//    static var textPrompt: String        {get {return NSLocalizedString("Text prompt", comment: "")}}
//    static var titleEachSide: String     {get {return NSLocalizedString("Must have a title for each side", comment: "")}}
    static var warning: String           {get {return NSLocalizedString("Warning", comment: "")}}

}

/*class TextBase {
    class var backBarButton: String     {return "Back"}
    
    class var deckTitle: String         {return "Decks"}
    class var newDeck: String           {return "New Deck"}
    class var logout: String            {return "Logout"}
    class var cancel: String            {return "Cancel"}
    class var logoutDialog: String      {return "Would you like to log out?"}
    class var continueNoSignIn: String  {return "Continue without sign in"}
    class var emailSignIn: String       {return "Email sign in"}
    class var googleSignIn: String      {return "Sign in with Google"}
    class var fbSignIn: String          {return "Sign in with Facebook"}
    class var languageOptions: String   {return "Choose language"}
    class var forgetPassword: String    {return "Forgot password"}
    class var newPWemail: String        {return "Would you like to receive a password recovery email?"}
    
    class var download: String          {return "Download"}
    class var cannotDownload: String    {return "Downloaded content not accessible at this time."}
    class var buy: String               {return "Buy "}
    class var overwriteWarning: String  {return "This will restore your previously downloaded deck to its default state.  Any edits will be lost."}
    class var cantSave: String          {return "Unable to save data to disk"}
    class var noName: String            {return "No name"}
    class var free: String              {return "Free"}
    
    class var reviewAlert: String       {return "Time to review the following decks!"}
    
    class var newDeckName: String       {return "New deck name"}
    class var newCubeName: String       {return "Enter new cube name"}
    class var continueTxt: String       {return "Continue"}
    class var notice: String            {return "Notice:"}
    class var promptsCantBeSame: String {return "Question and answer prompts cannot be the same."}
    class var promptsCantBeSameTwo: String {return "Primary and secondary prompts cannot be the same."}
    class var mustEnterDeckName: String {return "Must enter a deck name"}
    class var mustEnterPromptName: String {return "Must enter title for each prompt"}
    class var noDoublePromptNames: String {return "No two prompts can have the same title"}
    class var titleEachSide: String     {return "Must have a title for each side"}
    class var atleastTwoSides: String   {return "Must have at least two sides"}
    class var ok: String                {return "OK"}
    class var createSides: String       {return "Create the sides of "}
    class var textFieldHint: String     {return "Add a title: eg. French Audio"}
    class var side: String              {return "Side "}
    class var text: String              {return "Text"}
    class var audio: String             {return "Audio"}
    class var image: String             {return "Image"}
    class var addSide: String           {return "Add another side"}
    class var saveNewDeck: String       {return "Save new deck"}
    class var save: String              {return "Save"}
    class var newDeckInstruction1: String {return "A Flash Cube side is just like the side of a flash card.  Add whatever it is you would like to learn."}
    class var overWriteDeckInfo: String {return "Changes made to deck will be permanent."}
    class var instructionText: String   {return "Select text and you can type in any language your device supports."}
    class var instructionAudio: String  {return "Select audio and you will be able to record and play back any sound."}
    class var instrucitonImage: String  {return "Select image to be able to load an image from your photo library."}
    class var newDeckInstruction2: String {return "Make up to six sides, any combination you like."}
    class var newDeckInstruction3: String {return "Slide entry to the left to delete."}
    
    class var deckOverviewTitle: String {return "Deck Overview"}
    class var numberInDeck: String      {return "Number of cubes:"}
    class var averageProficiency: String {return "Average proficiency:"}
    class var lastReview: String        {return "Latest review:"}
    class var never: String             {return "Never"}
    class var addEdit: String           {return "Add / Edit Flash Cubes"}
    class var choosePrompts: String     {return "Choose Review Prompts"}
    class var reviewDeck: String        {return "Begin deck review"}
    
    class var flashCubesTitle: String   {return "Flash Cubes"}
    class var addNew: String            {return "Add new"}
    
    class var textPrompt: String        {return "Text Prompt"}
    class var audioPrompt : String      {return "Audio Prompt"}
    class var imagePrompt: String       {return "Image Prompt"}
    class var addTextHere: String       {return "Add text here"}
    class var saveFlashCube: String     {return "Save Flash Cube"}
    class var warning: String           {return "Warning"}
    class var deleteWarningPrompt: String {return "Prompt will be deleted"}
    class var deleteWarningCube: String     {return "Flash Cube will be permenantly deleted!"}
    class var deleteWarningDeck: String {return "All deck data will be permenantly deleted!"}
    class var delete: String            {return "Delete"}
    class var error: String             {return "Error"}
    class var promptsLackData: String   {return "Enter data for two or more prompts"}
    
    class var audioPlaybackSpeed: String {return "Audio playback speed:"}
    class var greatjob: String          {return "Great job,"}
    class var learnedNew1: String       {return "You learned "}
    class var learnedNew2: String       {return " new words."}
    class var remasteredOld1: String    {return "You remastered "}
    class var remasteredOld2: String    {return " previously learned words."}
    class var keepGoing: String         {return "Keep going"}
    class var stopForNow: String        {return "Stop for now"}
    
    class var overDueFinished: String   {return "Great job!  All of the due Flash Cubes have been reviewed.  Keep going?"}
    class var newStackFinished: String  {return "Great job!  You learned a new set of FLash Cubes.  Keep going?"}
    class var quitReview: String        {return "Quit reviewing?"}
    class var quit: String              {return "Quit"}
    class var noValidCubes: String      {return "The Flash Cubes in your deck do not have the prompts requested."}
    
    class var sortBy: String            {return "Sort by:"}
    class var sortNameAsc: String       {return "Deck name ascending"}
    class var sortNameDesc: String       {return "Deck name descending"}
    class var sortDueAsc: String        {return "Due date ascending"}
    class var sortDueDesc: String       {return "Due date descending"}
    class var sortRetAsc: String        {return "Retention ascending"}
    class var sortRetDesc: String       {return "Retention descending"}
    class var sortProfAsc: String        {return "Proficiency ascending"}
    class var sortProfDesc: String       {return "Proficiency descending"}
}*/
