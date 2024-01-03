
window.onload = () => {
    const ResourceName = "blossom_jobform";

    const FormContainer = document.getElementById("container");
    const FormHeading = document.getElementById("heading");
    const Form = document.getElementById("form");

    const ContactInput = document.getElementById("contact");
    const SubmitButton = document.getElementById("submit");
    const CloseButton = document.getElementById("close");

    let FirstNameElement = null;
    let LastNameElement = null;
    let PlayerNameElement = null;

    const QuestionsContainer = document.getElementById("questions");

    const ShowForm = (form, player) => {
        FormContainer.style.display = "block";

        if(form.color)
            FormContainer.style.backgroundColor = form.color;
        else
            FormContainer.style.backgroundColor = "rgb(44, 44, 44)";

        FormHeading.innerText = form.label;
        if(player.firstName) {
            FirstNameElement = document.createElement("p");
            FirstNameElement.setAttribute("id", "first-name");
            FirstNameElement.innerText = player.firstName;

            LastNameElement = document.createElement("p");
            LastNameElement.setAttribute("id", "last-name");
            LastNameElement.innerText = player.lastName;

            Form.prepend(FirstNameElement);
            Form.prepend(LastNameElement);
        } else {
            PlayerNameElement = document.createElement("p");
            PlayerNameElement.setAttribute("id", "player-name");
            PlayerNameElement.innerText = player.playerName;

            Form.prepend(PlayerNameElement);
        }

        ContactInput.value = player.contact;

        for(let [questionKey, questionData] of Object.entries(form.questions)) {
            const questionLabel = document.createElement("h3");
            questionLabel.innerText = questionData.label;

            QuestionsContainer.append(questionLabel);

            const questionTextarea = document.createElement("textarea");
            questionTextarea.setAttribute("id", `question-${questionKey}`);

            if(questionData.maxLength)
                questionTextarea.setAttribute("maxlength", questionData.maxLength);
            if(questionData.minLength)
                questionTextarea.setAttribute("minlength", questionData.minLength);
            
            QuestionsContainer.append(questionTextarea);
        }
    };

    const HideForm = () => {
        FormContainer.style.display = "none";
        if(FirstNameElement) {
            FirstNameElement.remove();
            FirstNameElement = null;

            LastNameElement.remove();
            LastNameElement = null;
        } else {
            PlayerNameElement.remove();
            PlayerNameElement = null;
        }
        ContactInput.value = "";
        QuestionsContainer.innerHTML = "";
    };
    
    SubmitButton.onclick = () => {
        const questionElements = document.getElementsByTagName("textarea");
        let questions = {};

        for(let i=0; i < questionElements.length; i++) {
            const element = questionElements[i];
            const questionKey = element.getAttribute("id").replace("question-", "");
            questions[questionKey] = element.value;
        }

        const contact = ContactInput.value;

        fetch(`https://${ResourceName}/submit`, {
            method: "POST",
            body: JSON.stringify({
                questions,
                contact,
            })
        });

        HideForm();
    };

    CloseButton.onclick = () => {
        HideForm();
        fetch(`https://${ResourceName}/exit`, {
            method: "POST",
            body: JSON.stringify({})
        });
    };

    document.onkeydown = (e) => {
        if(e.code == "Escape") {    
            HideForm();
            fetch(`https://${ResourceName}/exit`, {
                method: "POST",
                body: JSON.stringify({})
            });
        }
    };

    window.addEventListener("message", function(event) {
        const { action, form, player } = event.data;
        if(action == "showForm") 
            ShowForm(form, player);
    });
};
/*$(function () {
    function display(bool) {
        if(bool) {
            $("#container").show();
        } else {
            $("#container").hide();
        };
    };

    function setData(item) {
        var data = item.player;
        $("#heading").text(item.label);
        $("#firstname").text('Firstname: ' + data.firstname);
        $("#lastname").text('Lastname: ' + data.lastname);
        $("#phone_number").text('Phone: ' + data.phone);
    };

    display(false)

    window.addEventListener("message", function(event) {
        item = event.data;
        if(item.type === "ui") {
            if(item.status == true) {
                display(true);
                setData(item);
            } else {
                display(false);
            };
        };
    });

    document.onkeyup = function (data) {
        if (data.which == 27) {
            $.post("http://strin_jobform/exit_form", JSON.stringify({}));
            return
        }
    };

    $("#close").click(function() {
        $.post("http://strin_jobform/exit_form", JSON.stringify({}));
        return
    })

    $("#submit").click(function() {
        let text1 = $("#textarea_wayjoc").val()
        let text2 = $("#textarea_tuaby").val()
        $.post("http://strin_jobform/send_form", JSON.stringify({
            wayjoc: text1,
            tuaby: text2,
            job: item.job,
            label: item.label,
        }));
        return;
    });

})*/