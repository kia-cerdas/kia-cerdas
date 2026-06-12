package command

// import (
// 	"log"

// 	application "monitoring-service/app"

// 	"github.com/spf13/cobra"
// )

// var seedDummyCmd = &cobra.Command{
// 	Use:   "seed-dummy",
// 	Short: "Seed dummy KIA data",
// 	Run: func(cmd *cobra.Command, args []string) {
// 		app := application.New()
// 		if err := app.Init(); err != nil {
// 			log.Fatalf("Error initializing application: %+v", err)
// 		}

// 		if err := app.SeedDummyData(); err != nil {
// 			log.Fatalf("Error running dummy seed: %+v", err)
// 		}

// 		log.Println("Dummy data seeded successfully")
// 	},
// }

// func init() {
// 	cmdRoot.AddCommand(seedDummyCmd)
// }
