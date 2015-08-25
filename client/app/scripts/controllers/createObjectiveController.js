function CreateObjectiveController($scope, $window, toastr, StepsService, ObjectiveFactory) {
    $scope.objective = {
        name: "",
        description:"",
        subobjectives_attributes: [{
                name: "",
                description: ""
        }]
    };

    // Functions for moving the form / validation
    $scope.validateObjectivePortion = function() {
        if (!$scope.objective.name || $scope.objective.name.length === 0) {
            toastr.error("Objective name is required", 'Error');
            StepsService.steps().cancel();
        }
    };

    $scope.validateSubbjectivePortion = function() {
        var valid = true;
        var error = "";
        if ($scope.objective.subobjectives_attributes.length > 0) {
            var subs = $scope.objective.subobjectives_attributes;
            for (var i in subs) {
                if (subs[i].name === "") {
                    error = "A subobjective must have a name";
                    valid = false;
                }
            }
        } else {
            error = "Atleast one subobjective is required";
            valid = false;
        }

        if (valid) {
            $scope.createObjective();
        } else {
            toastr.error(error,'Error');
        }
    };

    // Functions for the adding / removing subobjectives to the form
    $scope.showRemoveSubobjectiveButton = function() {
        return $scope.objective.subobjectives_attributes.length > 1;
    };

    $scope.showAddSubobjectiveButton = function(isLast) {
        //isLast is used to only show the button if the iteration is the last iteration
        var subs = $scope.objective.subobjectives_attributes;
        var shouldShow = true;
        for (var i in subs) {
            // Check to ensure there are only valid subobjectives so far (All fields filled in)
            if (subs[i].name === "" && subs[i].description === "") {
                shouldShow = false;
            }
        }
        if (shouldShow) {
            if (!isLast) {
                shouldShow = false;
            }
        }
        return shouldShow;
    };

    $scope.removeSub = function(index) {
        $scope.objective.subobjectives_attributes.splice(index,1);
    };

    $scope.addAnotherSub = function() {
        var newSub = {
            name: "",
            description: "",
            active: true
        };
        $scope.objective.subobjectives_attributes.push(newSub);
    };

    //

    function clearObjectiveFields() {
        $scope.objective = {
            name: "",
            description:"",
            subobjectives_attributes: [{
                    name: "",
                    description: ""
            }]
        };
    }

    function cleanObjective() {
        var objective = $scope.objective;
        var subs = objective.subobjectives_attributes;
        for (var i in subs) {
            if (subs[i].name === "" && subs[i].description === "") {
                subs.splice(i,1);
            }
        }
        objective.subobjectives_attributes = subs;
        return objective;
    }

    $scope.createObjective = function() {
        var objective = cleanObjective();
        ObjectiveFactory.createObjective(objective)
            .success(function(obj) {
                $window.location.href = '/#/objectives/' + obj['id'];
                toastr.success("You successfully created an objective", 'Success');
                $scope.$emit('tidyUp');
                clearObjectiveFields();
            })
            .error(function(error) {
                toastr.error("The objective could not be created", 'Error');
            })
    };
};

angular
    .module('trackto')
    .controller('CreateObjectiveController', ['$scope','$window','toastr','StepsService','ObjectiveFactory', CreateObjectiveController])
